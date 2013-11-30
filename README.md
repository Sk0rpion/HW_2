HW_2
====
Я убрал часть реализации из игры. Вам необходимо реализовать код который я удалил, и связать визуальное представление с кодом.
<img src="https://raw.github.com/Sk0rpion/HW_2/master/Homa.gif" alt="Demo" width="491" height="510" />
Приложение должно корректно масштабироватся при изменении ориентации.
## Кратко о frame
Изменение frame у view:
```objective-c
view.frame = CGRectMake(0, 0, 100, 200);
//увеличение ширины на 10 пикселей
CGRect frame = view.frame;
frame.size.width += 10;
view.frame = frame;
//или
view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width + 10, view.frame.size.height);
```
