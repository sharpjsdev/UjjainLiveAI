const mysql = require('mysql2/promise');
const fs = require('fs');

async function updateDb() {
  try {
    const fullContext = fs.readFileSync('e:/AI app/ujjaincontext', 'utf8').trim();
    console.log(`Read master ujjaincontext file: ${fullContext.length} characters`);

    const conn = await mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: '',
      database: 'simhastha_db',
      port: 3306
    });

    const sql = "INSERT INTO `knowledge_context` (`id`, `title`, `category`, `content`, `updated_at`) " +
      "VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP) " +
      "ON DUPLICATE KEY UPDATE `title` = VALUES(`title`), `category` = VALUES(`category`), `content` = VALUES(`content`), `updated_at` = CURRENT_TIMESTAMP";

    const [res] = await conn.execute(sql, [
      'ujjain_city_guide',
      'Ujjain City AI Guide - Master Knowledge Context',
      'city_guide',
      fullContext
    ]);

    console.log(`SUCCESS: MySQL knowledge_context row updated! Affected rows: ${res.affectedRows}`);
    console.log(`SUCCESS: MySQL knowledge_context row updated with 100% full context! Affected rows: ${res.affectedRows}`);
    await conn.end();
  } catch (err) {
    console.error('MySQL Update Error:', err.message);
  }
}

updateDb();

