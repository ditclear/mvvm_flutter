
import 'package:rxdart/rxdart.dart';

main(){
  final s = ReplaySubject<int>();
  s.listen((s){
    print("S");
  });

  s.sink.add(1);
  s.sink.add(3);
  s.sink.add(3);
  s.sink.add(3);
  s.sink.add(3);
  s.sink.add(5);



}