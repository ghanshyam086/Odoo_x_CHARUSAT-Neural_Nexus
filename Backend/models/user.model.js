const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  fullName: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true }, // Hash this in production!
  age: { type: Number },
  gender: { type: String, enum: ['Male', 'Female', 'Other'] },
  height: { type: Number }, // in cm
  weight: { type: Number }, // in kg
  goals: { type: String }, // e.g., "weight loss", "stress relief"
  dietaryPreference: { type: String }, // e.g., "vegetarian", "vegan"
  profilePicture: { type: String }, // Path to uploaded image
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('User', userSchema);