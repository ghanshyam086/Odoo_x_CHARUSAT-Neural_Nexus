// lib/PortSection/ConfigFile.dart
const String baseUrl = 'http://172.16.218.216:3000/';
const String registration = '${baseUrl}registration';
const String login = '${baseUrl}login';
const String addTodo = '${baseUrl}storeTodo';
const String getToDoList = '${baseUrl}getUserTodoList';
const String deleteTodo = '${baseUrl}deleteTodo';
const String getBloodReports = '${baseUrl}api/blood-reports/';
const String addBloodReport = '${baseUrl}api/blood-reports/';
const String addPost = '${baseUrl}api/posts';
const String getPosts = '${baseUrl}api/posts';
const String likePost = '${baseUrl}api/likes';
const String getDoctors = '${baseUrl}doctors'; // Updated for new doctor endpoint
const String imageBaseUrl = '${baseUrl}uploads/'; // Assuming uploads/ for photos