const express = require('express');
const router = express.Router();
const { getCities, getDistricts, getHospitals, getHospitalById, createHospital } = require('../controllers/hospitalController');

router.get('/cities', getCities);
router.get('/districts', getDistricts);
router.get('/', getHospitals);
router.get('/:id', getHospitalById);
router.post('/', createHospital); // Added POST route

module.exports = router;