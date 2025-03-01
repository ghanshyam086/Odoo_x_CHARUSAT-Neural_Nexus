const express = require('express');
const router = express.Router();
const {
  createOrUpdateProfile,
  getProfile,
} = require('../controllers/user.controller'); // Verify this path

// Routes
router.post('/profile', createOrUpdateProfile); // This is line 6 where the error occurs
router.get('/profile/:email', getProfile);

module.exports = router;