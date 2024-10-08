import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Functions/functions.dart';
import '../screens/addBus.dart';
import 'dropdowncheckboxitem.dart';

class DropdownCheckbox extends StatefulWidget {
  final List<DropdownCheckboxItem> items;
  final TextEditingController controller;
  DropdownCheckbox({required this.items, required this.controller});
  @override
  _DropdownCheckboxState createState() => _DropdownCheckboxState();
}
class _DropdownCheckboxState extends State<DropdownCheckbox> {

  deleteSupervisor(DropdownCheckboxItem item) async {
    print('deleteSupervisor called');

    try {
      await FirebaseFirestore.instance
          .collection('supervisor')
          .doc(item.docID)
          .update({'bus_id': ''});

      print('Supervisor deleted successfully');

      // Remove the item from the selectedItems list
      selectedItems.removeWhere((items) => items.docID == item.docID);

      setState(() {
        // Trigger a rebuild of the widget tree if necessary
      });
    } catch (e) {
      print('Error deleting supervisor: $e');
      // Handle specific error cases here
    }
  }


  void updateSelectedNames() {
    setState(() {
      if (selectedItems.isEmpty) {
        selectedNames = "";
      } else if (selectedItems.length == 1) {
        selectedNames = selectedItems[0].label;
      } else {
        selectedNames = selectedItems.map((item) => item.label).join(', ');
      }
      widget.controller.text = selectedNames;
    });
  }
  bool isDropdownOpened = false;
  String selectedNames='Supervisor';
  TextEditingController _supervisorController = TextEditingController();
@override
  void initState() {
  // if(selectedItems.isNotEmpty){
  // if(selectedItems.length == 2){
  //   selectedNames =selectedItems[0].label+ ','+selectedItems[1].label;
  // }else {
  //   selectedNames = selectedItems[0].label;
  // }
  // }
    super.initState();
    updateSelectedNames();
  }
  @override
  Widget build(BuildContext context) {

    return
      DropdownButtonHideUnderline(
      child:
      SizedBox(
        width: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  isDropdownOpened = !isDropdownOpened;
                });
              },
              child:

              Container(

                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFFF1F1F1),
                  border: Border.all(color: Color(0xFFFFC53E),width: 0.5),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child:
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Text(selectedNames,

                      style: TextStyle(color: Color(0xFF442B72), fontSize: 12,
                      fontFamily: 'Poppins-Medium',),),
                   Image.asset("assets/imgs/school/Vector (12).png",width: 14,height: 9,),
                   // Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            if (isDropdownOpened)
              Align(alignment: AlignmentDirectional.bottomStart,
                child: Container(


                  child: Column(
                    children: widget.items.map((item) {
                      return Transform.scale(
                        scale: 1.2,
                        child: CheckboxListTile(
                          visualDensity: VisualDensity.compact,
                          checkboxShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0), // Adjust the border radius as needed

                          ),
                            //side: BorderSide(color: Color(0xFF442B72),width: 2),
                          //to make border appear in checked and not checked
                          side: MaterialStateBorderSide.resolveWith(
                                (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return const BorderSide(color: Color(0xFF442B72),width: 1.5);
                              }
                              return const BorderSide(color: Color(0xFF442B72),width: 1.5);
                            },
                          ),
                          checkColor:  Color(0xFF442B72),
                          activeColor: Colors.white,
                          // activeColor: Color(0xFF442B72) ,
                           //tileColor: Colors.white,
                          selectedTileColor: Color(0xFF442B72),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.0), // Adjust the padding as needed
                          controlAffinity: ListTileControlAffinity.leading, // Align checkbox to the left
                          title: Text(item.label,style: TextStyle(color:Color(0xFF442B72), ),),
                          value: item.isChecked,
                          onChanged: (value) {
                            setState(() {
                              if (value!) {
                                print('checkdataaa');
                                 if(selectedItems.length < 2){
                                   selectedItems.add(item); // Add to selected items list
                                   item.isChecked = value;
                                   updateSelectedNames();
                                   // if(selectedItems.length == 2){
                                   //   selectedNames =selectedItems[0].label+ ','+selectedItems[1].label;
                                   // }else{
                                   //   selectedNames =selectedItems[0].label;
                                   //
                                   // }
                                 }


                              } else {
                              //  selectedItems.remove(item);
                                selectedItems.removeWhere((items) => items.docID == item.docID);


                                item.isChecked = false;
                                deleteSupervisor(item).then((_) {
                                  updateSelectedNames();
                                });

                                // Clear text field value when unselecting
                                selectedNames =selectedItems[0].label;
                                //selectedItems.remove(item); // Remove from selected items list
                              // _supervisorController.clear();
                              }
                            });
                            // setState(() {
                            //   item.isChecked = value!;
                            // });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}