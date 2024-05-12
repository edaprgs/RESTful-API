import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SSIS | Paragoso',
      home: Scaffold(
        appBar: AppBar(
          title: const Text(''),
        ),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Center(
            child: Column(
              children: [
                const Text(
                  "STUDENT INFORMATION SYSTEM",
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
                SizedBox(height: 10), 
                Divider( 
                  color: Colors.black12, 
                  thickness: 0.5, 
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Align buttons in the center horizontally
                  children: [
                    Builder(builder: (context) {
                      return ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => coursePage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 190, 52, 85),
                          foregroundColor: Colors.white,
                          elevation: 0.0,
                          shadowColor: Colors.transparent,
                        ),
                        child: const Text('Course'),
                      );
                    }),
                    SizedBox(width: 30), // Add spacing between the buttons
                    Builder(builder: (context) {
                      return ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => studentPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 190, 52, 85),
                          foregroundColor: Colors.white,
                          elevation: 0.0,
                          shadowColor: Colors.transparent,
                        ),
                        child: const Text('Student'),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class coursePage extends StatefulWidget {
  @override
  State<coursePage> createState() => _CoursePageState();
}

class studentPage extends StatefulWidget {
  @override
  State<studentPage> createState() => _StudentPageState();
}

class _CoursePageState extends State<coursePage> {
  static const String apiUrl = '127.0.0.1:5000';
  dynamic courseDetails;
  bool isLoading = true;

  TextEditingController courseController = TextEditingController();
  TextEditingController deleteController = TextEditingController();
  TextEditingController editCourseIdController = TextEditingController();
  TextEditingController editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCourseDetails();
  }

  Future<void> fetchCourseDetails() async {
    try {
      final Uri url = Uri.http(apiUrl, '/courses');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final dynamic body = json.decode(response.body);
        if (body is Map<String, dynamic>) {
          final List<dynamic> courses = body['Message'];
          setState(() {
            courseDetails = courses;
            isLoading = false; // Update isLoading to false after data is fetched
          });
        } else {
          throw Exception('Invalid response format or status is not "ok"');
        }
      } else {
        throw Exception('Failed to load details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching replay details: $e');
      setState(() {
        isLoading = false; // Update isLoading to false in case of error
      });
    }
  }

  Future<void> addCourse(String course_name) async {
    final Uri url = Uri.http(apiUrl, '/course');
    final Map<String, String> requestBody = {
      'course': course_name,
    };

    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        print('Course added successfully');
        courseController.clear();
      } else {
        print('Failed to add course. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }

    await refreshCourses();
  }

  Future<void> editCourse(int courseId, String newCourseName) async {
    final Uri url = Uri.http(apiUrl, '/course/$courseId');
    final Map<String, String> requestBody = {
      'course': newCourseName,
    };

    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        print('Course edited successfully');
        courseController.clear();
      } else {
        print('Failed to edit course. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }

    await refreshCourses();
  }

  Future<void> deleteCourse(int courseId) async {
    final Uri url = Uri.http(apiUrl, '/course/$courseId');

    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.delete(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        print('Course deleted successfully');
      } else {
        print('Failed to deleted course. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }

    await refreshCourses();
  }

  Future<void> refreshCourses() async {
    setState(() {
      isLoading = true; 
    });

    await fetchCourseDetails();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Information System | Course'),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Add Course', style: TextStyle(fontSize: 18),),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: courseController,
                                decoration: InputDecoration(
                                  labelText: 'Course Name',
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Color.fromARGB(255, 190, 52, 85)), 
                                  ),
                                  labelStyle: TextStyle(
                                    color: Color.fromARGB(255, 190, 52, 85)
                                  ),
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color.fromARGB(255, 190, 52, 85)),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color.fromARGB(255, 190, 52, 85)), // Specify the border color for the bottom border
                                  ),
                                ),
                              ),
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Color.fromARGB(255, 190, 52, 85), 
                              ),
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                // Add the course
                                await addCourse(courseController.text);
                                // Refresh the course list
                                await refreshCourses();
                                // Close the dialog
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 190, 52, 85), 
                                foregroundColor: Colors.white, 
                                elevation: 0.0,
                                shadowColor: Colors.transparent,
                              ),
                              child: Text('Add'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 190, 52, 85), 
                    foregroundColor: Colors.white, 
                    elevation: 0.0,
                    shadowColor: Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 3),
                      Text('Course'),
                    ],
                  ),
                ),
              ],
            ),
            if (isLoading)
              CircularProgressIndicator(), // Show a loading indicator while fetching data
            if (courseDetails != null)
              Expanded(
                child: ListView.builder(
                  itemCount: courseDetails.length,
                  itemBuilder: (context, index) {
                    final course = courseDetails[index];
                    return Card(
                      child: ListTile(
                        title: Text('Name: ${course['course_name']}'),
                        subtitle: Text('ID: ${course['course_id'].toString()}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Color.fromARGB(255, 190, 52, 85),),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Edit Course', style: TextStyle(fontSize: 18),),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('Current Course Name: ${courseDetails[index]['course_name']}'),
                                          SizedBox(height: 20),
                                          TextField(
                                            controller: editController,
                                            decoration: InputDecoration(
                                              labelText: 'New Course Name',
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Color.fromARGB(255, 190, 52, 85)), 
                                              ),
                                              labelStyle: TextStyle(
                                                color: Color.fromARGB(255, 190, 52, 85)
                                              ),
                                              border: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Color.fromARGB(255, 190, 52, 85)),
                                              ),
                                              enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Color.fromARGB(255, 190, 52, 85)), // Specify the border color for the bottom border
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Color.fromARGB(255, 190, 52, 85), 
                                          ),      
                                          child: Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            editCourse(courseDetails[index]['course_id'], editController.text);
                                            Navigator.of(context).pop(); // Close the dialog
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color.fromARGB(255, 190, 52, 85), 
                                            foregroundColor: Colors.white, 
                                            elevation: 0.0,
                                            shadowColor: Colors.transparent,
                                          ),
                                          child: Text('Edit'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Delete Course', style: TextStyle(fontSize: 18),),
                                      content: Text(
                                          'Are you sure you want to delete this course?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Color.fromARGB(255, 190, 52, 85), 
                                          ), 
                                          child: Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            deleteCourse(courseDetails[index][
                                                'course_id']); // Delete course by ID
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color.fromARGB(255, 190, 52, 85), 
                                            foregroundColor: Colors.white, 
                                            elevation: 0.0,
                                            shadowColor: Colors.transparent,
                                          ),
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StudentPageState extends State<studentPage> {
  static const String apiUrl = '127.0.0.1:5000';
  dynamic studentDetails;
  bool isLoading = true;

  TextEditingController studentController = TextEditingController();
  TextEditingController courseController = TextEditingController();
  TextEditingController deleteController = TextEditingController();
  TextEditingController editController = TextEditingController();
  TextEditingController editCourseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchstudentDetails();
  }

  Future<void> fetchstudentDetails() async {
    try {
      final Uri url = Uri.http(apiUrl, '/students');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final dynamic body = json.decode(response.body);
        if (body is Map<String, dynamic>) {
          final List<dynamic> students = body['Message'];
          setState(() {
            studentDetails = students;
            isLoading = false; // Update isLoading to false after data is fetched
          });
        } else {
          throw Exception('Invalid response format or status is not "ok"');
        }
      } else {
        throw Exception('Failed to load details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching replay details: $e');
      setState(() {
        isLoading = false; // Update isLoading to false in case of error
      });
    }
  }

  Future<void> addStudent(String student_name, course_id) async {
    final Uri url = Uri.http(apiUrl, '/student');
    final Map<String, String> requestBody = {
      'student': student_name,
      'course_id': course_id,
    };

    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        print('Student added successfully');
        studentController.clear();
        courseController.clear();
      } else {
        print('Failed to add student. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }

    await refreshStudents();
  }

  Future<void> editStudent(
      int studentId, String newStudentName, String newCourseId) async {
    final Uri url = Uri.http(apiUrl, '/student/$studentId');
    final Map<String, String> requestBody = {
      'student': newStudentName,
      'course_id': newCourseId,
    };

    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        print('Student edited successfully');
        editController.clear();
        editCourseController.clear();
      } else {
        print('Failed to edit student. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }

    await refreshStudents();
  }

  Future<void> deleteStudent(int studentId) async {
    final Uri url = Uri.http(apiUrl, '/student/$studentId');

    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.delete(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        print('Student deleted successfully');
      } else {
        print('Failed to deleted student. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }

    await refreshStudents();
  }

  Future<void> refreshStudents() async {
    setState(() {
      isLoading = true; 
    });

    await fetchstudentDetails();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Information System | Student'),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Add Student', style: TextStyle(fontSize: 18),),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: studentController,
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Color.fromARGB(255, 190, 52, 85)), 
                                  ),
                                  labelStyle: TextStyle(
                                    color: Color.fromARGB(255, 190, 52, 85)
                                  ),
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color.fromARGB(255, 190, 52, 85)),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color.fromARGB(255, 190, 52, 85)), // Specify the border color for the bottom border
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              TextField(
                                controller: courseController,
                                decoration: InputDecoration(
                                  labelText: 'Course ID',
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Color.fromARGB(255, 190, 52, 85)), 
                                  ),
                                  labelStyle: TextStyle(
                                    color: Color.fromARGB(255, 190, 52, 85)
                                  ),
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color.fromARGB(255, 190, 52, 85)),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color.fromARGB(255, 190, 52, 85)), // Specify the border color for the bottom border
                                  ),
                                ),
                              ),
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Color.fromARGB(255, 190, 52, 85), 
                              ),
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                // Add the course
                                await addStudent(studentController.text, courseController.text);
                                // Refresh the course list
                                await refreshStudents();
                                // Close the dialog
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 190, 52, 85), 
                                foregroundColor: Colors.white, 
                                elevation: 0.0,
                                shadowColor: Colors.transparent,
                              ),
                              child: Text('Add'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 190, 52, 85), 
                    foregroundColor: Colors.white, 
                    elevation: 0.0,
                    shadowColor: Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 3),
                      Text('Student'),
                    ],
                  ),
                ),
              ],
            ),
            if (isLoading)
              CircularProgressIndicator(), // Show a loading indicator while fetching data
            if (studentDetails != null)
              Expanded(
                child: ListView.builder(
                  itemCount: studentDetails.length,
                  itemBuilder: (context, index) {
                    final student = studentDetails[index];
                    return Card(
                      child: ListTile(
                        title: Text('Name: ${student['student_name']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ID: ${student['student_id']}'),
                            Text('Course: ${student['course_name']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Color.fromARGB(255, 190, 52, 85),),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Edit Student', style: TextStyle(fontSize: 18),),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('Student Name: ${studentDetails[index]['student_name']}'),
                                          Text('Course: ${studentDetails[index]['course_name']}'),
                                          SizedBox(height: 20),
                                          TextField(
                                            controller: editController,
                                            decoration: InputDecoration(
                                              labelText: 'New Student Name',
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Color.fromARGB(255, 190, 52, 85)), 
                                              ),
                                              labelStyle: TextStyle(
                                                color: Color.fromARGB(255, 190, 52, 85)
                                              ),
                                              border: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Color.fromARGB(255, 190, 52, 85)),
                                              ),
                                              enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Color.fromARGB(255, 190, 52, 85)), // Specify the border color for the bottom border
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          TextField(
                                            controller: editCourseController,
                                            decoration: InputDecoration(
                                              labelText: 'New Course by ID',
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Color.fromARGB(255, 190, 52, 85)), 
                                              ),
                                              labelStyle: TextStyle(
                                                color: Color.fromARGB(255, 190, 52, 85)
                                              ),
                                              border: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Color.fromARGB(255, 190, 52, 85)),
                                              ),
                                              enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Color.fromARGB(255, 190, 52, 85)), // Specify the border color for the bottom border
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Color.fromARGB(255, 190, 52, 85), 
                                          ),      
                                          child: Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            editStudent(studentDetails[index]['student_id'], editController.text, editCourseController.text);
                                            Navigator.of(context).pop(); // Close the dialog
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color.fromARGB(255, 190, 52, 85), 
                                            foregroundColor: Colors.white, 
                                            elevation: 0.0,
                                            shadowColor: Colors.transparent,
                                          ),
                                          child: Text('Edit'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Delete Student', style: TextStyle(fontSize: 18),),
                                      content: Text(
                                          'Are you sure you want to delete this student?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Color.fromARGB(255, 190, 52, 85), 
                                          ), 
                                          child: Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            deleteStudent(studentDetails[index][
                                                'student_id']); // Delete course by ID
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color.fromARGB(255, 190, 52, 85), 
                                            foregroundColor: Colors.white, 
                                            elevation: 0.0,
                                            shadowColor: Colors.transparent,
                                          ),
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ), 
          ],
        ),
      ),
    );
  }
}
