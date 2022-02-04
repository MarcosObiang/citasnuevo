abstract class Presentation{
/// Must be called when the use case returns a [Failure] type object
void showErrorDialog(String errorLog);
///Must be called when the [UseCase.call()] function has not finished yet
void showLoadingDialog();}