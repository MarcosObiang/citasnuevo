abstract class ModuleCleaner {
  /// #From the presetation to the data source, every module needs to implement this method.
  ///
  ///In this function we set every variable to its initial state, this is needed in case the user switch accouns
  ///
  ///it is mandatory to leave every part in default mode to not mix any data

   clearModuleData();

  /// Used to  start any module after a module needed to be cleared because an error or because the user changed in the same device
  ///
  /// CAUTION: This method should be called after [clearModuleData] method, wich depending the case will need a different implementation
  /// 
  /// Make sure to call first [clearModuleData] to avoid errors and unexpected behaviour
   initializeModuleData();
}
