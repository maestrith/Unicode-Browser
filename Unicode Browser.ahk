#SingleInstance,Force
global Doc,Body,wb,Width,Height,Count:=49,Start
Width:=800
Height:=600
Gui,+HWNDMain
ID:="ahk_id" Main
Gui,Font,c0xAAAAAA
Gui,Color,0,0
Gui,Margin,0,0
IniRead,Start,Settings.INI,Settings,Start,0
IniRead,Count,Settings.INI,Settings,Count,66
Gui,Add,Edit,vStart w200,%Start%
Gui,Add,Edit,x+M vCount w200
Gui,Add,UpDown,Range10-200,%Count%
Hotkey,IfWinActive,%ID%
for a,b in {Enter:"Enter","+Enter":"Back"}
	Hotkey,%a%,%b%,On
Browser:=New Unicode_Browser("Black","Pink")
GuiControl,+gStart,Edit1
GuiControl,+gStart,Edit2
Total:=462
CC:=0
Start:=0
return
Class Unicode_Browser{
	__New(Background:="Black",Color:="Pink"){
		this.FixIE(11)
		Gui,Add,ActiveX,xm w%Width% h%Height% vwb,mshtml
		wb.Navigate("about:blank")
		while(wb.ReadyState!=4)
			Sleep,10
		this.Style:=(this.Body:=(this.Doc:=wb.Document).Body).Style
		this.Doc.ParentWindow.ahk_event:=this._Event.Bind(this)
		this.Style.BackgroundColor:=Background
		Gui,Show
		this.Style.Color:=Color
		this.Show(Start)
	}_Event(Event,Node){
		static
		Node:=Node.srcElement
		CTRL:=this
		if(GetKeyState("Shift"))
			MsgBox,,Unicode Browser,% ((Clipboard:=Node.GetAttribute("Name")) " Coppied to the Clipboard"),1
		else
			MsgBox,,Unicode Browser,% ((Clipboard:="&" Node.ID) " Coppied to the Clipboard"),1
	}FixIE(Version=0){ ;Thanks GeekDude
		local
		static Key:="Software\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION",Versions:={7:7000,8:8888,9:9999,10:10001,11:11001}
		Version:=Versions[Version]?Versions[Version]:Version
		if(A_IsCompiled)
			ExeName:=A_ScriptName
		else
			SplitPath,A_AhkPath,ExeName
		RegRead,PreviousValue,HKCU,%Key%,%ExeName%
		if(!Version)
			RegDelete,HKCU,%Key%,%ExeName%
		else
			RegWrite,REG_DWORD,HKCU,%Key%,%ExeName%,%Version%
		return PreviousValue
	}Show(Start:=100,CC:=0){
		global
		Control:="Internet Explorer_Server1"
		Control,Hide,,%Control%,A
		Loop,%Count%
		{
			if(A_Index=1)
				List:="<table><tr>"
			else if(Mod(A_Index,Ceil(Sqrt(Count))+2)=1)
				List.="</tr><tr>"
			Char:=Format("{:04x}",A_Index+Start)
			List.="<td UnSelectable='on' Name='" A_Index+Start "' Title='&#x" Char "`n`n#x" Char "' ID='#x" Char ";'>" "&#x" Char ";" (CC?"#x" Char:"")
		}
		this.Body.InnerHTML:=List "</tr></table>Enter to go to next set, Shift+Enter to go to previous set, Click an item to Copy its Code, Shift+Click for Decimal<Style>table th,td{Border:1px Solid Grey;Padding:8px;Font-Size:50px}table td{Cursor:Hand}.ToolTipText{Visibility:Hidden}</Style>"
		Script:=this.Doc.CreateElement("Script")
		Script.InnerText:="onclick=function(event){ahk_event('OnClick',event);" Chr(125) ";oncontextmenu=function(event){ahk_event('oncontextmenu',event)" Chr(125)
		this.Body.AppendChild(Script)
		this.Body.Style.OverFlow:="Auto"
		this.Body.Style.Margin:="0px"
		while(wb.ReadyState!=4&&wb.ReadyState!=1)
			Sleep,10
		Style:=this.Doc.GetElementsByTagName("Style").Item[0]
		Table:=this.Doc.GetElementsByTagName("Table").Item[0]
		Increment:=5,Size:=50
		while(!Table.ScrollWidth){
			Sleep,10
		}if(Table.ScrollWidth){
			while(Table.ScrollWidth<Width){
				Style.InnerText:="table th,td{Border:1px Solid Grey;Padding:8px;Font-Size:" (Size:=Size+Increment) "px}"
				if(Size>=100)
					Break
			}
		}
		while(this.Body.ScrollWidth>Width){
			Style.InnerText:="table th,td{Border:1px Solid Grey;Padding:8px;Font-Size:" (Size:=Size-Increment) "px}"
			if(Size<10)
				Break
		}
		while(this.Body.ScrollHeight>Height){
			Style.InnerText:="table th,td{Border:1px Solid Grey;Padding:8px;Font-Size:" (Size:=Size-Increment) "px}"
			if(Size<10)
				Break
		}
		Control,Show,,%Control%,A
		Gui,Show
	}
}
Enter:
Gui,Submit,Nohide
Browser.Show(Start+=Count,0)
ControlSetText,Edit1,%Start%,A
return
Back:
Gui,Submit,Nohide
Browser.Show((Start:=Start-Count<=0?0:Start-Count),0)
ControlSetText,Edit1,%Start%,A
return
Start:
if(!IsObject(wb))
	return
Gui,Submit,Nohide
Browser.Show(Start)
return
GuiClose:
GuiEscape:
Gui,Submit,Nohide
IniWrite,%Start%,Settings.INI,Settings,Start
IniWrite,%Count%,Settings.INI,Settings,Count
ExitApp
return