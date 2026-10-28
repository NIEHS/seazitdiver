# NTP Shared Header/Footer Update and Jquery Update

The NTP Public Website features a common shared header/footer across multiple websites and applications.
Reference: https://wiki.niehs.nih.gov/pages/viewpage.action?pageId=1850994.

There are two implementation options (I personal suggest use Shared version):

- Shared: contains only the CSS and JavaScript files necessary for duplicating the look and functionality of the NTP
  Public Website's header and footer, minimizing unnecessary dependencies and potential style conflicts.
- Full: utilizes all bundled CSS and JavaScript files used on the NTP Public Website. It provides functionality beyond
  the header and footer, enabling all features in the NTP Style Guide & Pattern Library.

Both implementations utilize:

- Foundation - responsive framework (version 6.7.4 as of the 04/2022 release)
- jQuery - JavaScript library (version 3.7.0 as of the 07/2023 release)
- jQuery UI - UI interactions for search autocomplete (version 1.13.2 as of the 07/2023 release)
- FontAwesome - CSS font icon library (version 4.7.0 as of the 01/2018 release)

Lastest version download:

- https://wiki.niehs.nih.gov/pages/viewpage.action?pageId=1850994

## Shared Release Version Update to Code.

An example to update files with Shared Release Version. If you download latest Zip file (such as 2023-07 Shared
Release.zip), after unzip it,
you should see those files, I will explain how to use them:

- footer.txt:
    - Copy & Paste & Replace footer.html (seazitdiver/project/templates/includes/footer.html)
    - Check if this line exists in seazitdiver/project/templates/base.html
  ```
         {% block footer %}
         {% include 'includes/footer.html' %}
         {% endblock footer %} 
  ```
- header.txt
    - Copy & Paste & Replace header.html (seazitdiver/project/templates/includes/header.html)
    - Check if this line exists in seazitdiver/project/templates/base.html
  ```
         {% block header %}
         {% include 'includes/header.html' %}
         {% endblock header %} 
  ```
- css folder:
    - Copy & Paste & Replace ntpweb-shared.css (seazitdiver/project/static_seazit/css/ntpweb-shared.css)
    - Check if this line exists in seazitdiver/project/templates/base.html
  ```
         <link href="{{STATIC_URL}}css/ntpweb-shared.css"
          rel="stylesheet" type="text/css"/>
  ```

- js folder: this js folder is a little complicated, I will explain it. The js folder contains those:
    - element folder:
        - jquery-3.7.0
        - jquery-ui-1.13.2
    - minimal-no-frameworks folder:
        - ntpweb-shared-minimal.js
        - ntpweb-shared-minimal.min.js
    - ntpweb-shared.js
    - ntpweb-shared.min.js

js folder files are used for updating javascript necessary scripts (such as jquery). If we want to update jqeury for
example, we have 2 methods to do that with given files, I personally suggest to use method 1.

1. First method: only update ntpweb-shared.js, this file contain jquery updated content.
    - a. Copy & Paste & Replace ntpweb-shared.js (seazitdiver/project/static_seazit/js/ntpweb-shared.js)
    - b. Checkout this file seazitdiver/project/templates/base.html, check if ntpweb-shared.js file is script
      implemented. Such as this code:
      ```
      <script src="{{STATIC_URL}}js/ntpweb-shared.js"
      type='text/javascript'></script>
      ```
2. Second method: update ntpweb-shared-minimal.js and element folder. ntpweb-shared-minimal.js does not contain jquery
   script, so you need to script jquery files.
    - a. Copy & Paste & Replace ntpweb-shared-minimal.js (seazitdiver/project/static_seazit/js/ntpweb-shared-minimal.js)
    - b. Checkout this file seazitdiver/project/templates/base.html, check if ntpweb-shared.js file is script
      implemented. Such as this code:
      ```
      <script src="{{STATIC_URL}}js/ntpweb-shared-minimal.js"
      type='text/javascript'></script>
      ```
    - c. Copy & Paste & Replace /jquery-3.7.0 and /jquery-ui-1.13.2 into this directory:
      seazitdiver/project/static_seazit/js/

If you check those 2 methods, you will find out they are different method and can not work together. Right.  They can not.
So keep in
mind do you script both files. If you used both files or more files inside base.html, that could cause code not working:

## Full Release Version Update to Code.

The full release version update is quite similar to shared release. It contains more html, javascript script, however,
it could cause more trouble because duplicated script implemented. The update method can follow as shared method, each
file inforamtion can be found in this link:
https://wiki.niehs.nih.gov/pages/viewpage.action?pageId=1850994

## CSS Release Version Update to Code.
ntpweb-shared.css file is updated for each release version. 
There are 2 ways to use NTP css files. One is to download file and use in the local project directory. Another is link to NTP website server. See below. 
See below.


    <link href="{{ STATIC_URL }}css/ntpweb-shared.css"
          rel="stylesheet" type="text/css"/>

    <link rel="stylesheet" type="text/css"
            href="https://ntp.niehs.nih.gov/themes/ntp/dist/css/ntpweb-shared.css"/>


CSS file will use some image file, font format file, and svg files. There are times it can not access those files.
I figured out solutions for 2 methods, and they are still in test version. 

1.  Local implement method (I personally do not like)
When I download css file into local directory, some code in css file not working. Mostly this kind. 'url()' 
For example. Below not working, because app can not find this file. 
`
    background-image: url(/sites/default/files/images/template/logo_bg.png);
`
Then I downloaded this file, and saved it in project directory (/seazitdiver/project/static_seazit/img/seazit/logo_bg.png)). Eventually changed it in css code, it works.
`
    background-image: url(../img/seazit/logo_bg.png);

`
Then I downloaded font files and images one by one. That is very long time job. 

2. Directly link NTP server. (Recommend)
This method is not tested yet, but it can save us time in the future.

## Quest. 
If you have questions, you can contain me via email.
### Zicong Wang [C]
Software Engineer, DNTP

- **Email:** zicong.wang@nih.gov
- **Office:** 9842874494
- **Address:** 530 DAVIS DR, Bldg: Keystone Building Rm: 2098, Durham, NC 27713
