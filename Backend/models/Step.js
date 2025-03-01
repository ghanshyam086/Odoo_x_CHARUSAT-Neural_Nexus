const mongoose = require('mongoose');

const stepSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  todayStepGoal: { type: Number, default: 50000 },
  stepsTaken: { type: Number, default: 0 },
  date: { type: Date, default: Date.now },
  cleared: { type: Boolean, default: false },
});

module.exports = mongoose.model('Step', stepSchema);