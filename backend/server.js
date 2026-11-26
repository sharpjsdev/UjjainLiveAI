const http = require('http');
const path = require('path');
const url = require('url');
const fs = require('fs');
require('dotenv').config();
const pool = require('./database');

const PORT = process.env.PORT || 3000;
const PUBLIC_DIR = path.join(__dirname, 'public');

function setCorsHeaders(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, Accept, ngrok-skip-browser-warning');
}

function parseBody(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', chunk => { body += chunk.toString(); });
    req.on('end', () => {
      try {
        resolve(body ? JSON.parse(body) : {});
      } catch (e) {
        resolve({});
      }
    });
    req.on('error', err => reject(err));
  });
}

const server = http.createServer(async (req, res) => {
  setCorsHeaders(res);

  // Handle ngrok browser warning bypass
  // ngrok free tier shows a warning page, these headers help bypass it
  res.setHeader('ngrok-skip-browser-warning', 'true');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  const parsedUrl = url.parse(req.url, true);
  const pathname = parsedUrl.pathname;

  // Serve Admin Dashboard HTML frontend
  if (pathname === '/' || pathname === '/admin' || pathname === '/index.html') {
    const indexPath = path.join(PUBLIC_DIR, 'index.html');
    if (fs.existsSync(indexPath)) {
      res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
      res.end(fs.readFileSync(indexPath));
      return;
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // USER CHAT LOGS (Store Questions Asked by User & Answers Given by AI)
  // ══════════════════════════════════════════════════════════════════════
  if (pathname === '/api/chat-logs' || pathname === '/api/chat_logs') {
    try {
      if (req.method === 'POST') {
        const body = await parseBody(req);
        const { sessionId, question, answer, language, isVoice } = body;
        if (!question || !answer) {
          res.writeHead(400, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: 'question and answer are required' }));
          return;
        }
        const [result] = await pool.query(
          "INSERT INTO `chat_logs` (`session_id`, `question`, `answer`, `language`, `is_voice`) VALUES (?, ?, ?, ?, ?)",
          [sessionId || null, question, answer, language || 'hi', isVoice ? 1 : 0]
        );
        res.writeHead(201, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: true, logId: result.insertId }));
        return;
      }

      if (req.method === 'GET') {
        const [rows] = await pool.query("SELECT * FROM `chat_logs` ORDER BY `created_at` DESC LIMIT 100");
        res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' });
        res.end(JSON.stringify(rows || []));
        return;
      }
    } catch (err) {
      console.error('[MySQL ChatLog Error]:', err);
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: err.message }));
      return;
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // SYNC MASTER KNOWLEDGE CONTEXT FROM FILE TO MYSQL
  // ══════════════════════════════════════════════════════════════════════
  if (pathname === '/api/sync-context' && req.method === 'POST') {
    try {
      const candidates = [
        path.join(__dirname, '..', 'ujjaincontext'),
        path.join(__dirname, 'data', 'knowledge_context.json'),
      ];
      let content = '';
      for (const p of candidates) {
        if (fs.existsSync(p)) {
          content = fs.readFileSync(p, 'utf8').trim();
          break;
        }
      }
      if (!content) {
        res.writeHead(404, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Master context file (ujjaincontext) not found' }));
        return;
      }
      await pool.query(
        "INSERT INTO `knowledge_context` (`id`, `title`, `category`, `content`, `updated_at`) " +
        "VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP) " +
        "ON DUPLICATE KEY UPDATE `title` = VALUES(`title`), `category` = VALUES(`category`), `content` = VALUES(`content`), `updated_at` = CURRENT_TIMESTAMP",
        ['ujjain_city_guide', 'Ujjain City AI Guide - Master Knowledge Context', 'city_guide', content]
      );
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: true, message: 'Master knowledge context synced from file successfully!', length: content.length }));
      return;
    } catch (e) {
      console.error('[Sync Context Error]:', e);
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: e.message }));
      return;
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // REST API ROUTING FOR MYSQL DATABASE
  // /api/temples
  // /api/events
  // /api/stays
  // /api/context
  // ══════════════════════════════════════════════════════════════════════
  const apiMatch = pathname.match(/^\/api\/(temples|events|stays|context)(?:\/([^/]+))?$/);

  if (apiMatch) {
    let table = apiMatch[1];
    if (table === 'context') table = 'knowledge_context';
    const itemId = apiMatch[2];

    try {
      // 1. GET ALL or GET BY ID
      if (req.method === 'GET') {
        if (itemId) {
          const query = table === 'knowledge_context'
            ? pool.query(`SELECT * FROM \`${table}\` WHERE \`id\` = ?`, [itemId])
            : pool.query(`SELECT * FROM \`${table}\` WHERE \`id\` = ? OR \`templeId\` = ?`, [itemId, itemId]);
          const [rows] = await query;
          if (rows && rows.length > 0) {
            _formatRowJson(table, rows[0]);
            res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' });
            res.end(JSON.stringify(rows[0]));
          } else {
            res.writeHead(404, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ error: 'Item not found in MySQL' }));
          }
        } else {
          const [rows] = await pool.query(`SELECT * FROM \`${table}\` ORDER BY \`created_at\` DESC`);
          (rows || []).forEach(row => _formatRowJson(table, row));
          res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' });
          res.end(JSON.stringify(rows || []));
        }
        return;
      }

      // 2. CREATE (POST)
      if (req.method === 'POST') {
        const body = await parseBody(req);
        const id = body.id || (table.slice(0, 3) + '_' + Date.now());
        body.id = id;

        if (table === 'temples') {
          const sql = `
            INSERT INTO \`temples\` 
            (\`id\`, \`templeId\`, \`templeName\`, \`hindiName\`, \`deity\`, \`significance\`, \`timing\`, \`imageUrl\`, \`aartis\`, \`entryGates\`, \`darshanRoutes\`, \`vipFastTrackRules\`, \`bookingWebsite\`, \`dressCode\`, \`prasadDetails\`)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          `;
          const params = [
            id, body.templeId || id, body.templeName || '', body.hindiName || '', body.deity || '',
            body.significance || '', body.timing || '', body.imageUrl || '', JSON.stringify(body.aartis || []),
            JSON.stringify(body.entryGates || []), JSON.stringify(body.darshanRoutes || []),
            body.vipFastTrackRules || '', body.bookingWebsite || '', body.dressCode || '', body.prasadDetails || ''
          ];
          await pool.query(sql, params);
        } else if (table === 'knowledge_context') {
          const sql = `
            INSERT INTO \`knowledge_context\` (\`id\`, \`title\`, \`category\`, \`content\`)
            VALUES (?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE \`title\` = VALUES(\`title\`), \`category\` = VALUES(\`category\`), \`content\` = VALUES(\`content\`), \`updated_at\` = CURRENT_TIMESTAMP
          `;
          await pool.query(sql, [id, body.title || 'Knowledge Context', body.category || 'temple_guide', body.content || '']);
        } else if (table === 'events') {
          const sql = `
            INSERT INTO \`events\` 
            (\`id\`, \`title\`, \`hindiTitle\`, \`date\`, \`tithi\`, \`significance\`, \`hindiSignificance\`, \`location\`, \`isShahiSnan\`, \`type\`)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          `;
          const params = [
            id, body.title || '', body.hindiTitle || '', body.date || '', body.tithi || '',
            body.significance || '', body.hindiSignificance || '', body.location || '',
            body.isShahiSnan ? 1 : 0, body.type || 'parva_snan'
          ];
          await pool.query(sql, params);
        } else if (table === 'stays') {
          const sql = `
            INSERT INTO \`stays\` 
            (\`id\`, \`name\`, \`hindiName\`, \`category\`, \`lat\`, \`lon\`, \`icon\`, \`area\`, \`description\`, \`hindiDescription\`, \`contact\`, \`timing\`, \`gates\`, \`pricing\`, \`rating\`, \`tags\`)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          `;
          const params = [
            id, body.name || '', body.hindiName || '', body.category || 'hotel',
            parseFloat(body.lat) || 23.18, parseFloat(body.lon) || 75.77,
            body.icon || '🏨', body.area || '', body.description || '', body.hindiDescription || '',
            body.contact || '', body.timing || '', body.gates || '', body.pricing || '',
            parseFloat(body.rating) || 4.5, JSON.stringify(body.tags || [])
          ];
          await pool.query(sql, params);
        }

        res.writeHead(201, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: true, item: body }));
        return;
      }

      // 3. UPDATE (PUT)
      if (req.method === 'PUT') {
        if (!itemId) {
          res.writeHead(400, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: 'Missing ID' }));
          return;
        }

        const body = await parseBody(req);
        if (table === 'temples') {
          const sql = `
            UPDATE \`temples\` SET 
              \`templeName\` = ?, \`hindiName\` = ?, \`deity\` = ?, \`significance\` = ?, \`timing\` = ?,
              \`imageUrl\` = ?, \`vipFastTrackRules\` = ?, \`bookingWebsite\` = ?, \`dressCode\` = ?, \`prasadDetails\` = ?
            WHERE \`id\` = ? OR \`templeId\` = ?
          `;
          const params = [
            body.templeName || '', body.hindiName || '', body.deity || '', body.significance || '', body.timing || '',
            body.imageUrl || '', body.vipFastTrackRules || '', body.bookingWebsite || '', body.dressCode || '', body.prasadDetails || '',
            itemId, itemId
          ];
          await pool.query(sql, params);
        } else if (table === 'events') {
          const sql = `
            UPDATE \`events\` SET 
              \`title\` = ?, \`hindiTitle\` = ?, \`date\` = ?, \`tithi\` = ?, \`significance\` = ?,
              \`hindiSignificance\` = ?, \`location\` = ?, \`isShahiSnan\` = ?
            WHERE \`id\` = ?
          `;
          const params = [
            body.title || '', body.hindiTitle || '', body.date || '', body.tithi || '', body.significance || '',
            body.hindiSignificance || '', body.location || '', body.isShahiSnan ? 1 : 0, itemId
          ];
          await pool.query(sql, params);
        } else if (table === 'stays') {
          const sql = `
            UPDATE \`stays\` SET 
              \`name\` = ?, \`hindiName\` = ?, \`category\` = ?, \`icon\` = ?, \`area\` = ?, 
              \`description\` = ?, \`contact\` = ?, \`pricing\` = ?
            WHERE \`id\` = ?
          `;
          const params = [
            body.name || '', body.hindiName || '', body.category || 'hotel', body.icon || '🏨', body.area || '',
            body.description || '', body.contact || '', body.pricing || '', itemId
          ];
          await pool.query(sql, params);
        } else if (table === 'knowledge_context') {
          const sql = `
            UPDATE \`knowledge_context\` SET \`title\` = ?, \`category\` = ?, \`content\` = ?
            WHERE \`id\` = ?
          `;
          await pool.query(sql, [body.title || 'Knowledge Context', body.category || 'temple_guide', body.content || '', itemId]);
        }

        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: true, item: { ...body, id: itemId } }));
        return;
      }

      // 4. DELETE
      if (req.method === 'DELETE') {
        if (!itemId) {
          res.writeHead(400, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: 'Missing ID' }));
          return;
        }

        const deleteQuery = table === 'knowledge_context'
          ? pool.query(`DELETE FROM \`${table}\` WHERE \`id\` = ?`, [itemId])
          : pool.query(`DELETE FROM \`${table}\` WHERE \`id\` = ? OR \`templeId\` = ?`, [itemId, itemId]);
        await deleteQuery;
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: true, message: 'Deleted from MySQL database' }));
        return;
      }
    } catch (err) {
      console.error('MySQL API Error:', err);
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: err.message }));
      return;
    }
  }

  res.writeHead(404, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ error: 'Endpoint not found' }));
});

function _formatRowJson(table, row) {
  if (table === 'temples') {
    if (typeof row.aartis === 'string') { try { row.aartis = JSON.parse(row.aartis); } catch (_) { row.aartis = []; } }
    if (typeof row.entryGates === 'string') { try { row.entryGates = JSON.parse(row.entryGates); } catch (_) { row.entryGates = []; } }
    if (typeof row.darshanRoutes === 'string') { try { row.darshanRoutes = JSON.parse(row.darshanRoutes); } catch (_) { row.darshanRoutes = []; } }
  } else if (table === 'events') {
    row.isShahiSnan = (row.isShahiSnan === 1 || row.isShahiSnan === true);
  } else if (table === 'stays') {
    if (typeof row.tags === 'string') { try { row.tags = JSON.parse(row.tags); } catch (_) { row.tags = []; } }
  }
}

server.listen(PORT, '0.0.0.0', () => {
  console.log(`=======================================================`);
  console.log(`Simhastha Ujjain 2028 Node.js MySQL Server Running`);
  console.log(`Port: ${PORT}`);
  console.log(`MySQL Host: ${process.env.DB_HOST || 'localhost'}:${process.env.DB_PORT || 3306}`);
  console.log(`MySQL Database: ${process.env.DB_NAME || 'simhastha_db'}`);
  console.log(`Admin Portal: http://localhost:${PORT}/admin`);
  console.log(`REST APIs: /api/temples, /api/events, /api/stays, /api/context, /api/chat-logs`);
  console.log(`=======================================================`);
});
