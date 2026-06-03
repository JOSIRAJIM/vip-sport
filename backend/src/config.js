const config = {
  port: Number(process.env.PORT || 3000),
  jwtSecret: process.env.JWT_SECRET || "change_this_secret_before_production",
  db: {
    host: process.env.DB_HOST || "localhost",
    port: Number(process.env.DB_PORT || 3306),
    user: process.env.DB_USER || "sport_user",
    password: process.env.DB_PASSWORD || "sport_password_dev",
    database: process.env.DB_NAME || "sport_store",
    waitForConnections: true,
    connectionLimit: 10,
    namedPlaceholders: true,
    decimalNumbers: true
  }
};

module.exports = { config };
