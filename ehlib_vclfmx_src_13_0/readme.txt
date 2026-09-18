EhLib.VclFmx 13.0 Build 13.0.010 source included version (Professional Edition).
-------------------------------------------------

The Library contains components and classes for Borland Delphi and
C++ Builer 2010 - XE13, Lazarus.

TABLE OF CONTENTS
-----------------
Overview
Installation Library
Installation Help
Demonstration Programs
Library editions
Registering and Prices
Other information
About author


Where to start.
-------------------

Start overview of the library with the main Demo project
.\Demos\Bin\MainDemo.Exe.
(Compiled Demo files are available in the Evaluation version of the library)

If you've used previous versions of the library, then you can read a summary 
of the new features and changes in the file history-eng.html.

  More detail about new features in this version of the library 
  can be found in the file - "EhLib.VclFmx 13.0 Release Notes Eng.docx" 

To install a new version of the library in the IDE, use the installation program
.\Installer\EhLibInstaller.exe

  If, at the installation have any problems, write a letter to ehlib support
  address support@ehlib.com
  You can also install the files in the library IDE manually, as described in
  Section 2. Installation Library

After installation, make sure the operability of all installed components.
To do this, open the IDE, compile and launch a major demonstration project
.\Demos\MainDemo\Project1_XE2.dpr

You can read the technical specification for the library at the following address:
  https://www.ehlib.com/online-help/ehlib-vclfmx-12-1/EhLibDoc/02-specifications.html

You can read the documentation for the library at the following address:
  1. https://www.ehlib.com/en/ehlib.vcl-online-guide
  2. "<EhLib archive>\Hlp\ENG\EhLib - Users guide.doc" file

Read about EhLib for Lazarus in the file - Lazarus<*>\readme.txt

Overview
--------

The Library contains several components and objects.

TDBGridEh component
TDBGridEh provides all functionality of TDBGrid 
 and adds several new features as follows:
   Allows to select records, columns and rectangle areas.
   Special titles that can correspond to several/all columns.
   Footer that is able to show sum/count/other field values.
   Automatic column resizing to set grid width equal client width.
   Ability to change row and title height.
   Allows automatic broken of a single line long title and data row 
     to a multiline.
   Title can act as button and, optionally show a sort marker.
   Automatically sortmarking.
   Ability to truncate long text with ellipsis.
   Lookup list can show several fields.
   Incremental search in lookup fields.
   Frozen columns.
   DateTime picker support for TDateField and TDateTimeField.
   Allows to show bitmaps from TImageList depending on field value.
   Allows to hide and track horizontal or vertical scrollbars.
   Allows to hide columns.
   Allows to show 3D frame for frozen, footer and data rows.
   Allows to draw memo fields.
   Multiline inplace editor.
   Proportional scrolling independently of sequenced of dataset.
   Automatically show checkboxes for Boolean fields. Allows to show 
    checkboxes for other type of fields.
   Has a procedures to save and restore layout (visible columns, columns 
    order, columns width, sortmarkers, row height) in/from registry or ini file.
   Allows to show hint (ToolTips) for text that don't fit in the cell.
   Allows to export data to Text, Csv, HTML, RTF, XLS and internal formats.
   Allows to import data from Text and internal formats.
   Can sort data in various dataset's.
   Can filter data in various dataset's.
   When DBGridEh is connected to DataSet of TMemTable type it allows:
     To view all data without moving active record.
     To display a tree-type structure of TMemTable records.
     To form list of values in dropdown list of SubTitle filter automatically.
     To create grouping records basing on the selected coulmns.

TDBVertGridEh component
  Component to show one record from dataset in Vertical Orientation.
    Have a special column to show Field Captions
    Can customize inplace editor and data of the cell like in DBGridEh.

TDBLookupComboboxEh component
 Provides all functionality of TDBLookupCombobox and adds 
 several new features as follows:
   Can have flat style.  
   Allows assign values as to KeyValue property just and to 
     display Text property.
   Allows to type (assign) values to Text property not contained in data list
     (Style = csDropDownEh). 
   Allows to hold KeyValue and Text as not affecting to each other values. 
    Take effect when KeyField, ListField, ListSource, DataField and DataSource 
    properties is empty.
   Drop down list can:
     Show titles,
     Have sizing grip,
     Automaticaly set width as sum of DisplayWidth of the list fields (Width = -1),
     Automaticaly drops on user pressed the key.
   Edit button can:
     Show DropDown, Ellipsis or Bitmap image.
     Have specified width.
   Have additional events: OnKeyValueChanged, OnButtonClick.


TDBSumList component
This component is intended for totaling sums and amounts of records in a 
TDataSet with dynamic changes. Component keeps a list of TDBSum 
objects, which contains types of group operations (goSum or goCount) 
and name sum field (goCount name of field is unnecessary).


TPrintDBGridEh component
TPrintDBGridEh provides properties and routines for preview and 
  print of TDBGridEh component with several features:
    Ability to expand rows vertically until all text is printed.
    Ability to scale grid to fit it to page width.
    Ability to print/preview title for grid.
    Ability to print/preview page header and page footer where you can 
     specify macros for current page, current date, current time and/or static 
     text.
    Automatically print/preview multiselected area of TDBGridEh if it area 
     is not empty.
    Ability to print/preview rich text before and after grid.

TPreviewBox component
TPreviewBox lets you create a customizable runtime preview.


TPrinterPreview object
TPrinterPreview lets you to record printable data in buffer for following 
output them on screen and to printer. TPrinterPreview have all functions and 
properties as in TPrinter object. You can use TPrinterPreview object similarly 
of TPrinter except some details. In TPrinter Printer.Canvas.Handle and 
Printer.Handle is the same but in TPrinterPreview PrinterPreview.Canvas.Handle
represent the metafile in that is recored the data and PrinterPreview.Handle 
represent Printer.Handle. That is mean that you have to use 
PrinterPreview.Canvas.Handle for draw operation (DrawText, DrawTexteEx, e.t.c.) 
and use PrinterPreview.Handle in functions that return information about 
printer facilities (GetDeviceCaps, e.t.c.). Global function PrinterPreview 
returns default PrinterPreview object and shows data in default preview form.

TDBEditEh component 
represents a single or multi-line edit control that can display and edit a field 
in a dataset or can works as non data-aware edit control.

TDBDateTimeEditEh component 
represents a single-line date or time edit control that can display and edit 
a datetime field in a dataset or can works as non data-aware edit control.


TDBComboBoxEh component 
represents a single or multi-line edit control that combines an edit box 
with a scrollable list and can display and edit a field in a dataset or can 
works as non data-aware combo edit control.

TDBNumberEditEh component 
represents a single-line number edit control that can display and edit a numeric 
field in a dataset or can works as non data-aware edit control.


TPropStorageEh, TIniPropStorageManEh, TRegPropStorageManEh components
Components realize technology to store component properties to/from settings 
storage such as ini files, registry etc.

TMemTableEh component
 dataset, which hold data in memory. Its possible consider as an array of 
 records.
 Besides, it:
  Supports a special interface, which allows DBGridEh component  to view all 
    data without moving active record.
  Allows fetch data from TDataDriverEh object (DataDriver property).
  Allows unload change back in DataDriver, operative or postponed (in 
   dependencies of the CachedUpdates property).
  Allows to create a master/detail relations on the client (filtering record) 
   or on the external source (updating parameters [Params] and requiring data 
   from DataDriver).
  Allows once-only (without the dynamic support) sort data, including 
   Calculated and Lookup field.
  Allows create and fill data in design-time and save data in dfm file of the 
   Form.
  Allows keep record in the manner of trees. Each record can have record 
   elements-branches and itself be an element to other parental record. 
   Component TDBGridEh supports to show the tree-type structure of these 
   records.
  Allows to connect to the internal array of other TMemTableEh (via 
   ExternalMemData property) and work with its data: sort, filter, edit.
  Has interface for requesting list of all unique values in one column of 
   records array, ignoring local filter of the DataSet. TDBGridEh uses this 
   property for automatic filling a list in DropDownBox of the subtitle 
   filter cell.

TDataDriverEh component
  carry out two tasks:
    Delivers data to TMemTableEh.
    Processes changed records of TMemTableEh (writes them in other dataset, 
      or call events for processing the changes in program).

TSQLDataDriverEh
  DataDriver that have four objects of the TSQLCommandEh type: SelectCommand, 
  DeleteCommand, InsertCommand, UpdateCommand, GetrecCommand.
  TSQLDataDriverEh can not transfer queries to the server but it call global 
  (for application) event which it is necessary to write to execute SQL 
  expressions on the server.

TBDEDataDriverEh, TIBXDataDriverEh, TDBXDataDriverEh and TADODataDriverEh Components.
  These are SQLDataDrivers that can deliver queries to the server using 
  corresponding drivers of the access to datas.


--------------------
2. Installation Library
--------------------

--------------------
2.1  Installing library automatically
--------------------

Run EhLibInstaller.exe program from "Installer" folder to install EhLib in 
Delphi/C++ Builder IDE. The program creates folders to keep EhLib binary
and other requared files, copies requared files to created folders,
compiles packages, register packages in IDE and write requared paths 
in registry.

If you have executable installation program (for example, EhLibSetupD7Eval.exe)
then you only need to run program and follow installation process. Setup automatically
writes all units in necessary directory, installs packages and help files in IDE.


--------------------
2.2  Installing library manually
-------------------

Follow next instructions to install files from EhLib archive:

--
2.2.1. For RAD Studio XE2 (Delphi) or higher:
---------------------------------------------------------------------

Read file - "EhLib.VclFmx 12.0 Release Notes Eng.docx"


4. Documentation and Help
-------------------------

4.1. This version of library doesn't have embedded help files for Delphi8 or Higher.
     But the online help is available on the ehlib home page - 
     http://www.ehlib.com/online-help

5. Demonstration Programs and Projects
--------------------------------------

Demonstration programs use tables from the DEMOS directory 
and ADO Data Access.

Read description of Demo projects in the file
Demos\Info Eng.doc


6. Library editions
-------------------

The EhLib library is supplied in the “EhLib with source code” and “EhLib without source” editions.

The “EhLib with source code” edition contains the source code of the library in the Object Pascal language.

The “EhLib without source” edition contains only compiled binary files of the library 
for various versions of the IDE.

In addition, the “EhLib without source” edition contains the following restrictions:

- No binaries for Lazarus. EhLib without source does not support Lazarus.

- The binary files of the EhLibBDEDataDrivers and DclEhLibBDEDataDrivers packages are missing. 
  Accordingly, the TBDEDataDriverEh component is missing.


7. Registering and Prices
-------------------------

The EhLib is a Commercial product. If you find it useful and want to receive 
the latest versions please register your evaluation copy.

You can read detailed information about prices on ehlib home prices page
http://www.ehlib.com/buy

You can read detailed information about registration at 
https://secure.shareit.com/shareit/product.html?productid=102489

After registration you will receive (e-mail only) address of
registered version for downloading and password for unpacking.

By registering the components you get the following advantages:

1.  You  will  get new versions of the library free within a year from
the date of registration.
2. You will get technical support for the library all the time.
3. You encourage EhLib Team to make the library even better.


8. Other information
--------------------
                                                                                  
The ability to compile applications under Linux is available only in the 
EhLib version with source codes.


9. About Company
----------------

Contact us if you have any questions, comments or suggestions:
EhLib Team
www: http://www.ehlib.com
E-mail: support@ehlib.com
MS Teams support: ehlib.support