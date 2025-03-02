const mongoose = require('mongoose');

const hospitalSchema = new mongoose.Schema({
  name: { type: String, required: true },
  city: { type: String, required: true },
  district: { type: String, required: true },
  address: { type: String, required: true },
  contact: {
    phone: String,
    email: String,
    website: String,
  },
  operatingHours: String,
  emergencyServices: Boolean,
  departments: [String],
  treatments: [String],
  emergencyCare: String,
  specializedUnits: [String],
  doctors: [{
    name: String,
    specialty: String,
    experience: Number,
  }],
  consultationTimings: String,
  facilities: {
    beds: Number,
    pharmacy: Boolean,
    diagnostics: [String],
    ambulance: String,
  },
  insurance: [String],
  rating: Number,
  testimonials: [String],
  additional: {
    wellness: String,
    bloodBank: Boolean,
    medicalTourism: Boolean,
    covidUpdates: String,
  },
}, { timestamps: true });

module.exports = mongoose.model('Hospital', hospitalSchema);