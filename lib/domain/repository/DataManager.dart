abstract class DataManager{

/// #From the presetation to the data source, every module needs to implement this method.
///
///In this function we set every variable to its initial state, this is needed in case the user switch accouns
///
///it is mandatory to leave every part in default mode to not mix any data

bool clearModuleData();


}