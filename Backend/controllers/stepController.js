const Step = require('../models/Step');

exports.createStepEntry = async (req, res) => {
  try {
    const { userId, stepsTaken } = req.body;
    const today = new Date().setHours(0, 0, 0, 0);
    let stepEntry = await Step.findOne({ userId, date: { $gte: today } });

    if (!stepEntry) {
      stepEntry = new Step({ userId, stepsTaken });
    } else {
      stepEntry.stepsTaken = stepsTaken;
      stepEntry.cleared = stepsTaken >= stepEntry.todayStepGoal;
    }

    await stepEntry.save();
    res.status(201).json(stepEntry);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getStepEntry = async (req, res) => {
  try {
    const { userId } = req.params;
    const today = new Date().setHours(0, 0, 0, 0);
    const stepEntry = await Step.findOne({ userId, date: { $gte: today } });
    res.status(200).json(stepEntry || { userId, stepsTaken: 0, todayStepGoal: 50000, cleared: false });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getWeeklyStreaks = async (req, res) => {
  try {
    const { userId } = req.params;
    const weekAgo = new Date();
    weekAgo.setDate(weekAgo.getDate() - 7);

    const streaks = await Step.find({
      userId,
      date: { $gte: weekAgo },
      cleared: true,
    });

    res.status(200).json({ streakCount: streaks.length });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};