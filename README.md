<h1>CirclePicker</h1>
by Tim Kreuzer

CirclePicker is a custom UIView. It allows multiple choice selection of different elements  which can be customised by the programmer. Furthermore you can configure CirclePicker for your own needs with multiple parameters.

<h2>Requirements</h2>
<ul>
  <li>iOS 9.0+</li>
  <li>Xcode 9.0+</li>
</ul>
<h2>Installation</h2>
<p>
Download and copy the files from "Code" to your Xcode-project and you're good to go.
</p>
<p>
You can also install CirclePicker using <a href="https://cocoapods.org/">CocoaPods</a>.
Add the following line in your Podfile:<br>
<code>pod 'CirclePicker'</code>
</p>
<h2>Usage</h2>
<p>
Create a new Object of the type CirclePicker. You need to set the dataSource attribute (CirclePickerDataSource-protocol) to fill it with data. Then you can use the method attachToView(_ :) to attach the picker to a certain view. The picker itself will be displayed now. In order to respond to user interaction, you need to set the delegate attribute (CirclePickerDelegate-protocol) which will be called on every interaction.<br>
</p>
