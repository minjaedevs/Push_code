const express = require("express");
const mysql = require("mysql2");
const cors = require("cors");
const swaggerUi = require("swagger-ui-express");
const swaggerJsdoc = require("swagger-jsdoc");

const app = express();
app.use(cors());
app.use(express.json());

// Cấu hình MySQL
const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "310501@@Dd",
  database: "phenikaa_university",
});

db.connect((err) => {
  if (err) {
    console.error("❌ MySQL connection error:", err);
    return;
  }
  console.log("✅ Connected to MySQL database!");
});

// Route test
app.get("/", (req, res) => {
  res.send("API is running...");
});

/**
 * @swagger
 * tags:
 *   name: Schools
 *   description: API quản lý Schools
 */

/**
 * @swagger
 * /schools:
 *   get:
 *     summary: Lấy danh sách tất cả schools
 *     tags: [Schools]
 *     responses:
 *       200:
 *         description: Danh sách schools
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 type: object
 */
app.get("/schools", (req, res) => {
  db.query("SELECT * FROM schools", (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

/**
 * @swagger
 * /schools/{id}:
 *   get:
 *     summary: Lấy thông tin 1 school theo id
 *     tags: [Schools]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Thông tin school
 *       404:
 *         description: Không tìm thấy
 */
app.get("/schools/:id", (req, res) => {
  const { id } = req.params;
  db.query("SELECT * FROM schools WHERE id = ?", [id], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    if (results.length === 0) return res.status(404).json({ message: "Not found" });
    res.json(results[0]);
  });
});

/**
 * @swagger
 * /schools:
 *   post:
 *     summary: Thêm mới 1 school
 *     tags: [Schools]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               id:
 *                 type: integer
 *               name:
 *                 type: string
 *               short_name:
 *                 type: string
 *               description:
 *                 type: string
 *               university_id:
 *                 type: integer
 *               dean_name:
 *                 type: string
 *               dean_email:
 *                 type: string
 *               office_location:
 *                 type: string
 *               phone:
 *                 type: string
 *               email:
 *                 type: string
 *     responses:
 *       201:
 *         description: School đã được tạo
 */
app.post("/schools", (req, res) => {
  const data = req.body;
  const query = `
    INSERT INTO schools 
    (id, name, short_name, description, university_id, dean_name, dean_email, office_location, phone, email)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `;
  db.query(query, [
    data.id, data.name, data.short_name, data.description, data.university_id,
    data.dean_name, data.dean_email, data.office_location, data.phone, data.email
  ], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ message: "School created", id: data.id });
  });
});

/**
 * @swagger
 * /schools/{id}:
 *   put:
 *     summary: Cập nhật school theo id
 *     tags: [Schools]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *     responses:
 *       200:
 *         description: School đã được cập nhật
 */
app.put("/schools/:id", (req, res) => {
  const { id } = req.params;
  const data = req.body;
  const query = `
    UPDATE schools SET 
      name = ?, short_name = ?, description = ?, university_id = ?, 
      dean_name = ?, dean_email = ?, office_location = ?, phone = ?, email = ?
    WHERE id = ?
  `;
  db.query(query, [
    data.name, data.short_name, data.description, data.university_id,
    data.dean_name, data.dean_email, data.office_location, data.phone, data.email,
    id
  ], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: "School updated" });
  });
});

/**
 * @swagger
 * /schools/{id}:
 *   delete:
 *     summary: Xoá school theo id
 *     tags: [Schools]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: School đã bị xoá
 */
app.delete("/schools/:id", (req, res) => {
  const { id } = req.params;
  db.query("DELETE FROM schools WHERE id = ?", [id], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: "School deleted" });
  });
});

// Swagger cấu hình
const options = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "Phenikaa University API",
      version: "1.0.0",
      description: "API CRUD cho bảng schools",
    },
    servers: [
      {
        url: "http://localhost:3000",
      },
    ],
  },
  apis: ["./server.js"], // nơi chứa @swagger comments
};

const swaggerSpec = swaggerJsdoc(options);
app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// Start server
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
