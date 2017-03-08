If WinExist ahk_class #32771  ; Indicates that the alt-tab menu is present on the screen.
    i::Up
    j::Left
    k::Down
    l::Right
return  

!i::Send { Up }
!j::Send { Left }
!k::Send { Down }
!l::Send { Right }

^!i::Send ^{ Up }
^!j::Send ^{ Left }
^!k::Send ^{ Down }
^!l::Send ^{ Right }

+!i::Send +{ Up }
+!j::Send +{ Left }
+!k::Send +{ Down }
+!l::Send +{ Right }

+^!i::Send +^{ Up }
+^!j::Send +^{ Left }
+^!k::Send +^{ Down }
+^!l::Send +^{ Right }

