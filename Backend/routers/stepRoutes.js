const express = require('express');
const { createStepEntry, getStepEntry, getWeeklyStreaks } = require('../controllers/stepController');
const router = express.Router();

router.post('/steps', createStepEntry);
router.get('/steps/:userId', getStepEntry);
router.get('/streaks/:userId', getWeeklyStreaks);

module.exports = router;