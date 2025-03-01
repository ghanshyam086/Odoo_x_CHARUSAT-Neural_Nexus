const User = require('../models/user.model');
const multer = require('multer');
const path = require('path');

// Multer setup
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `${Date.now()}${ext}`);
  },
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: (req, file, cb) => {
    const filetypes = /jpeg|jpg|png/;
    const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = filetypes.test(file.mimetype);
    if (extname && mimetype) {
      return cb(null, true);
    }
    cb(new Error('Only images (jpeg, jpg, png) are allowed!'));
  },
}).single('profilePicture');

// Create or update user profile
const createOrUpdateProfile = async (req, res) => {
  upload(req, res, async (err) => {
    if (err) {
      return res.status(400).json({ message: err.message });
    }

    try {
      const {
        fullName,
        email,
        password,
        age,
        gender,
        height,
        weight,
        goals,
        dietaryPreference,
      } = req.body;

      const userData = {
        fullName,
        email,
        password, // Hash this in production
        age,
        gender,
        height,
        weight,
        goals,
        dietaryPreference,
      };

      if (req.file) {
        userData.profilePicture = `/uploads/${req.file.filename}`;
      }

      const user = await User.findOneAndUpdate(
        { email },
        userData,
        { upsert: true, new: true }
      );

      res.status(200).json({ message: 'Profile saved successfully', user });
    } catch (error) {
      res.status(500).json({ message: 'Server error', error: error.message });
    }
  });
};

// Get user profile
const getProfile = async (req, res) => {
  try {
    const user = await User.findOne({ email: req.params.email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.status(200).json(user);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// Export the functions
module.exports = { createOrUpdateProfile, getProfile };