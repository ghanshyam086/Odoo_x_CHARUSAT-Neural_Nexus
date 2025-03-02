const Hospital = require('../models/Hospital');

exports.getCities = async (req, res) => {
  try {
    const cities = await Hospital.distinct('city');
    res.json(cities);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};

exports.getDistricts = async (req, res) => {
  const { city } = req.query;
  try {
    const districts = await Hospital.distinct('district', { city });
    res.json(districts);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};

exports.getHospitals = async (req, res) => {
  const { city, district } = req.query;
  try {
    const hospitals = await Hospital.find({ city, district });
    res.json(hospitals);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};

exports.getHospitalById = async (req, res) => {
  try {
    const hospital = await Hospital.findById(req.params.id);
    if (!hospital) return res.status(404).json({ message: 'Hospital not found' });
    res.json(hospital);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};

exports.createHospital = async (req, res) => {
  try {
    const hospital = new Hospital(req.body);
    await hospital.save();
    res.status(201).json(hospital);
  } catch (error) {
    res.status(400).json({ message: 'Invalid data', error });
  }
};