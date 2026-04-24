class Note{

  final int id;
  final String title;
  final String content;
  final String createdAt;
  final List subtasks;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.subtasks,
  });

  factory Note.fromJSON(Map<String,dynamic> json){
    return Note(
    id: json['id'],
    title: json['title'], 
    content: json['content'], 
    createdAt: json['created_at'], 
    subtasks: json['subtask']??[]);
  }

 


}