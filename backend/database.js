const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

// Create connection pool for high-concurrency MySQL access
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'simhastha_db',
  port: parseInt(process.env.DB_PORT || '3306', 10),
  waitForConnections: true,
  connectionLimit: 15,
  queueLimit: 0,
  charset: 'utf8mb4'
});

async function initDatabase() {
  try {
    // 1. Ensure the Database exists
    const rootConn = await mysql.createConnection({
      host: process.env.DB_HOST || 'localhost',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      port: parseInt(process.env.DB_PORT || '3306', 10)
    });

    const dbName = process.env.DB_NAME || 'simhastha_db';
    await rootConn.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`);
    await rootConn.end();

    // 2. Create Required Tables inside simhastha_db
    const conn = await pool.getConnection();

    await conn.query(`
      CREATE TABLE IF NOT EXISTS \`temples\` (
        \`id\` VARCHAR(100) PRIMARY KEY,
        \`templeId\` VARCHAR(100) NOT NULL,
        \`templeName\` VARCHAR(255) NOT NULL,
        \`hindiName\` VARCHAR(255) NOT NULL,
        \`deity\` VARCHAR(255),
        \`significance\` TEXT,
        \`timing\` VARCHAR(255),
        \`imageUrl\` TEXT,
        \`aartis\` JSON,
        \`entryGates\` JSON,
        \`darshanRoutes\` JSON,
        \`vipFastTrackRules\` TEXT,
        \`bookingWebsite\` VARCHAR(255),
        \`dressCode\` TEXT,
        \`prasadDetails\` TEXT,
        \`created_at\` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        \`updated_at\` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    await conn.query(`
      CREATE TABLE IF NOT EXISTS \`events\` (
        \`id\` VARCHAR(100) PRIMARY KEY,
        \`title\` VARCHAR(255) NOT NULL,
        \`hindiTitle\` VARCHAR(255) NOT NULL,
        \`date\` VARCHAR(100) NOT NULL,
        \`tithi\` VARCHAR(150),
        \`significance\` TEXT,
        \`hindiSignificance\` TEXT,
        \`location\` VARCHAR(255),
        \`isShahiSnan\` TINYINT(1) DEFAULT 0,
        \`type\` VARCHAR(50) DEFAULT 'parva_snan',
        \`created_at\` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        \`updated_at\` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    await conn.query(`
      CREATE TABLE IF NOT EXISTS \`stays\` (
        \`id\` VARCHAR(100) PRIMARY KEY,
        \`name\` VARCHAR(255) NOT NULL,
        \`hindiName\` VARCHAR(255) NOT NULL,
        \`category\` VARCHAR(50) NOT NULL,
        \`lat\` DECIMAL(10, 6),
        \`lon\` DECIMAL(10, 6),
        \`icon\` VARCHAR(20),
        \`area\` VARCHAR(255),
        \`description\` TEXT,
        \`hindiDescription\` TEXT,
        \`contact\` VARCHAR(100),
        \`timing\` VARCHAR(255),
        \`gates\` VARCHAR(255),
        \`pricing\` VARCHAR(255),
        \`rating\` DECIMAL(3, 1) DEFAULT 4.5,
        \`tags\` JSON,
        \`created_at\` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        \`updated_at\` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);


    // 4. Create knowledge_context Table for AI Assistant
    await conn.query(`
      CREATE TABLE IF NOT EXISTS \`knowledge_context\` (
        \`id\` VARCHAR(100) PRIMARY KEY,
        \`title\` VARCHAR(255) NOT NULL,
        \`category\` VARCHAR(100) NOT NULL,
        \`content\` LONGTEXT NOT NULL,
        \`created_at\` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        \`updated_at\` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    // 4. Seed knowledge_context table from data/knowledge_context.json
    const dataDir = path.join(__dirname, 'data');
    const contextJsonPath = path.join(dataDir, 'knowledge_context.json');
    if (fs.existsSync(contextJsonPath)) {
      const contextsData = JSON.parse(fs.readFileSync(contextJsonPath, 'utf8'));
      for (const ctx of contextsData) {
        const [existing] = await conn.query("SELECT id FROM `knowledge_context` WHERE id = ?", [ctx.id]);
        if (!existing || existing.length === 0) {
          const insertSql = 'INSERT INTO `knowledge_context` (`id`, `title`, `category`, `content`) VALUES (?, ?, ?, ?)';
          await conn.query(insertSql, [ctx.id, ctx.title, ctx.category || 'temple_guide', ctx.content]);
          console.log(`[MySQL] Seeded '${ctx.id}' knowledge context into MySQL database`);
        } else {
          const updateSql = 'UPDATE `knowledge_context` SET `content` = ?, `title` = ?, `category` = ?, `updated_at` = CURRENT_TIMESTAMP WHERE `id` = ?';
          await conn.query(updateSql, [ctx.content, ctx.title, ctx.category || 'temple_guide', ctx.id]);
          console.log(`[MySQL] Synced '${ctx.id}' with latest master knowledge context`);
        }
      }
    }

    // 5. Create chat_logs Table for saving User Questions & AI Answers
    await conn.query(`
      CREATE TABLE IF NOT EXISTS \`chat_logs\` (
        \`id\` INT AUTO_INCREMENT PRIMARY KEY,
        \`session_id\` VARCHAR(100),
        \`question\` TEXT NOT NULL,
        \`answer\` LONGTEXT NOT NULL,
        \`language\` VARCHAR(20) DEFAULT 'hi',
        \`is_voice\` TINYINT(1) DEFAULT 0,
        \`created_at\` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    // 6. Seed initial data for Temples, Events, and Stays if empty

    // Seed Temples
    const [templeRows] = await conn.query("SELECT COUNT(*) as count FROM `temples`");
    if (templeRows[0].count === 0 && fs.existsSync(path.join(dataDir, 'temples.json'))) {
      const templesData = JSON.parse(fs.readFileSync(path.join(dataDir, 'temples.json'), 'utf8'));
      for (const t of templesData) {
        await conn.query(
          "INSERT INTO `temples` (`id`, `templeId`, `templeName`, `hindiName`, `deity`, `significance`, `timing`, `imageUrl`, `aartis`, `entryGates`, `darshanRoutes`, `vipFastTrackRules`, `bookingWebsite`, `dressCode`, `prasadDetails`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
          [
            t.id, t.templeId || t.id, t.templeName || '', t.hindiName || '', t.deity || '',
            t.significance || '', t.timing || '', t.imageUrl || '', JSON.stringify(t.aartis || []),
            JSON.stringify(t.entryGates || []), JSON.stringify(t.darshanRoutes || []),
            t.vipFastTrackRules || '', t.bookingWebsite || '', t.dressCode || '', t.prasadDetails || ''
          ]
        );
      }
      console.log(`[MySQL] Seeded ${templesData.length} temples into MySQL database`);
    }

    // Seed Events
    const [eventRows] = await conn.query("SELECT COUNT(*) as count FROM `events`");
    if (eventRows[0].count === 0 && fs.existsSync(path.join(dataDir, 'events.json'))) {
      const eventsData = JSON.parse(fs.readFileSync(path.join(dataDir, 'events.json'), 'utf8'));
      for (const e of eventsData) {
        await conn.query(
          "INSERT INTO `events` (`id`, `title`, `hindiTitle`, `date`, `tithi`, `significance`, `hindiSignificance`, `location`, `isShahiSnan`, `type`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
          [
            e.id, e.title || '', e.hindiTitle || '', e.date || '', e.tithi || '',
            e.significance || '', e.hindiSignificance || '', e.location || '',
            e.isShahiSnan ? 1 : 0, e.type || 'parva_snan'
          ]
        );
      }
      console.log(`[MySQL] Seeded ${eventsData.length} events into MySQL database`);
    }

    // Seed Stays
    const [stayRows] = await conn.query("SELECT COUNT(*) as count FROM `stays`");
    if (stayRows[0].count === 0 && fs.existsSync(path.join(dataDir, 'stays.json'))) {
      const staysData = JSON.parse(fs.readFileSync(path.join(dataDir, 'stays.json'), 'utf8'));
      for (const s of staysData) {
        await conn.query(
          "INSERT INTO `stays` (`id`, `name`, `hindiName`, `category`, `lat`, `lon`, `icon`, `area`, `description`, `hindiDescription`, `contact`, `timing`, `gates`, `pricing`, `rating`, `tags`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
          [
            s.id, s.name || '', s.hindiName || '', s.category || 'hotel',
            parseFloat(s.lat) || 23.18, parseFloat(s.lon) || 75.77,
            s.icon || '🏨', s.area || '', s.description || '', s.hindiDescription || '',
            s.contact || '', s.timing || '', s.gates || '', s.pricing || '',
            parseFloat(s.rating) || 4.5, JSON.stringify(s.tags || [])
          ]
        );
      }
      console.log(`[MySQL] Seeded ${staysData.length} stays into MySQL database`);
    }

    conn.release();
    console.log(`Connected to MySQL Server & verified database '${dbName}'`);
  } catch (err) {
    console.warn(`[MySQL Notice] Connection to MySQL (${process.env.DB_HOST}:${process.env.DB_PORT}) failed:`, err.message);
    console.warn(`Make sure MySQL / WampServer / XAMPP is running on port ${process.env.DB_PORT || 3306}`);
  }
}

initDatabase();

module.exports = pool;
