const express = require('express');
const session = require('express-session');
const bodyParser = require('body-parser');
const userRouter = require('./routers/user.router'); // Verify this path
const app = express();

// Middleware
app.use(session({
  secret: 'your_secret_key',
  resave: false,
  saveUninitialized: true,
  cookie: { secure: false },
}));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use('/uploads', express.static('uploads'));

// Mount the user router
app.use('/api/users', userRouter);

module.exports = app;