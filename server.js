const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = 3000;
const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir);

const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, uploadDir),
    filename: (req, file, cb) => {
        // फ़ाइल नाम वही रहे जो क्लाइंट भेजे (rec_xxx.webm)
        cb(null, file.originalname);
    }
});
const upload = multer({ storage });

app.use(express.static(__dirname));
app.post('/upload', upload.single('video'), (req, res) => {
    if (!req.file) return res.status(400).json({ error: 'No file' });
    console.log(`✅ सुरक्षित सेव: ${req.file.filename} (${req.file.size} bytes)`);
    res.json({ success: true });
});
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 सर्वर चालू: http://localhost:${PORT}`);
});