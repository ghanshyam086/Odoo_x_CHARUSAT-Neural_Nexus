const mongoose = require('mongoose');

const postLikeSchema = new mongoose.Schema({
  postId: { type: mongoose.Schema.Types.ObjectId, ref: 'Post', required: true },
  userId: { type: String, required: true }, // Could be ObjectId if tied to a User model
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('PostLike', postLikeSchema);