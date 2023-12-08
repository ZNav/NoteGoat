; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force
    ;notes

;icon for taskbar
I_Icon = %A_ScriptDir%\goat.ico
IfExist, %I_Icon%
  Menu, Tray, Icon, %I_Icon%

    ;global variables, soon to be pulled from .txt file then later editted from a gui
global calibration := ["toggle slideout open status", 1350, 942, 300]
global noteTypedInfo := ["start keybind, end keybind, delete last key bool, input timeout, typing sleep", "\","\","^\", True, "T8", 900]
global operators := ["selected keybind, toggle slideout keybind, toggle slideout sleep", "^Insert", "Insert", 300]
global jwClick := ["jw click", 1,  17, 236, 500]
global wolClick := ["wol click", 1, 22, 287, 0]
global iconClick := ["wol icon", 1, 76, 166, 1000]
global searchClick := ["search bar", 1, 631, 162, 500]
global scriptureClick := ["scripture", 1, 161, 399, 1000]
global endVar := False

update(calibration, "settings\calibration.txt")
update(noteTypedInfo, "settings\noteType.txt")
update(operators, "settings\operators.txt")
update(jwClick, "settings\jwClick.txt")
update(wolClick, "settings\wolClick.txt")
update(iconClick, "settings\iconClick.txt")
update(searchClick, "settings\searchClick.txt")
update(scriptureClick, "settings\scriptureClick.txt")

    ;hotkeys for actions
;lookup what you are about to type
Hotkey, % noteTypedInfo[2], lookupInput, On
;lookup what you have selected
Hotkey, % operators[2], lookupSelected, On
;toggle slideout open status
Hotkey, % operators[3], toggleSlidout, On
;end lookupinput if pressed
Hotkey, % noteTypedInfo[4], endFunction, On

    ;functions
;copies selected text for scripture lookup
lookupSelected(){
    sleep 50
    Sendinput, ^{c}
    sleep 50
    useWol(Clipboard)
    return
}

endFunction(){
    endVar := True
}

;take what you type next as an input
lookupInput(){
    ;sets hotkey to off so you dont run multiple instances
    Hotkey, % noteTypedInfo[2], Off
    endVar := False
    endNote =  % noteTypedInfo[3]
    cancelNote = % noteTypedInfo[4]
    needDel =  % noteTypedInfo[5]
    timeout = % noteTypedInfo[6]
    ;take input until endkey pressed or timeout
    Input , noteInput, V %timeout%, {%endNote%}{%cancelNote%}
    ;if pressed cancelNote don't do continue fn
    if(endVar = True){
        Hotkey, % noteTypedInfo[2], On
        return
    }
    else{
        ;if the endkey is a char it will need deleted
        if(needDel = True and ErrorLevel != "Timeout"){
            send {BackSpace}
            }
        useWol(noteInput)
        return
    }
return
}

;uses wol to lookup scriptures
useWol(inputtedScripture){
    sleep 100
    ;sets hotkey to off so you dont run multiple instances
    Hotkey, % operators[2], Off
    ;IMPORTANT needed 0.3 second wait 
    ;clicks a differnet tab so that when clicking wol it doesn't toggle off if already open
    clickNew(jwClick[3], jwClick[4], jwClick[5], jwClick[2])
    ; click wol
    clickNew(wolClick[3], wolClick[4], wolClick[5], wolClick[2])
    ;click wt icon to clear search bar
    clickNew(iconClick[3], iconClick[4], iconClick[5], iconClick[2])
    ; click search bar
    clickNew(searchClick[3], searchClick[4], searchClick[5], searchClick[2])
    ; type input into search bar then enter
    send, %inputtedScripture%{ENTER}
    sleep % noteTypedInfo[7]
    ; click scripture
    clickNew(scriptureClick[3], scriptureClick[4], scriptureClick[5], scriptureClick[2])
    mouseGo()
    ;sets hotkey to on so they can be used again
    Hotkey, % noteTypedInfo[2], On
    Hotkey, % operators[2], On
    return
}

;calibration click / reactive cursor
mouseGo(){
    sleep % calibration[4]
    clickNew(calibration[2], calibration[3], 0, True)
    return
}

;toggle slideout open status
toggleSlidout(){
    Hotkey, % operators[3], Off
    sleep % operators[4]
    ; click wol
    clickNew(wolClick[3], wolClick[4], wolClick[5], wolClick[2])
    ;calibration click / reactive cursor
    mouseGo()
    Hotkey, % operators[3], On
    return
}

;lets you use expressions
clickNew(x, y, wait, active){
    if(active = 1){
        click %x%, %y%
        sleep %wait%
    }
    return
}

;settings

update(array, filePath){
    for i, line in array {
    FileReadLine, newVal, %A_ScriptDir%\%filePath%, i
    array[i] := newVal
    }
    Return
}