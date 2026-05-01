class SubTask {
  final int id;
  final String title;
  final bool completed;

  // 1. Normal Constructor
  SubTask({
    required this.id,
    required this.title,
    required this.completed,
  });

  // 2. Factory Constructor
  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
        id: json['id'], title: json['title'], completed: json['completed']);
  }
}

class Note {
  final int id;
  final String title;
  final String content;
  final String createdAt;
  final List<SubTask> subtasks;

//  1. Normal Constructor
  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.subtasks,
  });

// 2. factory constructor

  factory Note.fromJson(Map<String, dynamic> json) {
    // 1. Getting the raw list of map from th json
    var rawSubtasks = json['subtasks'] as List;

    // 2. Map each "Map" to a "SubTask Object" using the translator

    List<SubTask> subTaskList =
        rawSubtasks.map((eachMap) => SubTask.fromJson(eachMap)).toList();

    // 3. Return The finished Note object

    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: json['created_at'],
      subtasks: subTaskList,
    );
  }
}
