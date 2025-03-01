const express = require('express');
const router = express.Router();
const postController = require('../controllers/postController');

router.post('/', postController.createPost);
router.get('/', postController.getAllPosts);
router.get('/:id', postController.getPostById);
router.post('/likes', postController.likePost); // New endpoint for liking
router.get('/likes/:postId', postController.getPostLikes); // New endpoint for getting likes

module.exports = router;