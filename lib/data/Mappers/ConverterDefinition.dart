abstract class DataSourceConverter<T> {
  ///Convert data to [Map] from the object[T]
  ///
  ///
  Map<String, dynamic> toMap(T data);

  ///Convert Object type [T] too [Map]
  ///
  ///
  T fromMap(Map data);
}