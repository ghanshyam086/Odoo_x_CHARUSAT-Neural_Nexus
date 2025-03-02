const app = require('./app');
const db = require('./config/db');
const userModel = require('./models/user.model');
const express = require('express');
const reportRouter = require('./routers/report.router');
const bloodReportRoutes = require('./routers/bloodReport.router'); 
const postRoutes = require('./routers/postRoutes');
const doctorRoutes = require('./routers/doctorRoutes');
const stepRoutes = require('./routers/stepRoutes'); 
const cors = require('cors');
const hospitalRoutes = require('./routers/hospitalRoutes');

const port = 3000;

app.use(express.json());
app.use('/uploads', express.static('uploads'));
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static('uploads'));
app.use('/api/hospitals', hospitalRoutes);

// Routes
app.use('/api', stepRoutes);
app.use('/api/reports', reportRouter);
app.use('/api/blood-reports', bloodReportRoutes); 
app.use('/api/posts', postRoutes);

const fs = require('fs');
const path = require('path');
const uploadDir = path.join(__dirname, 'uploads');
app.use('/', doctorRoutes);
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir);
}

app.get('/', (req, res) => {
    res.send("Hello World");
});

app.listen(port, () => {
    console.log(`Server listening on port http://localhost:${port}`);
});

