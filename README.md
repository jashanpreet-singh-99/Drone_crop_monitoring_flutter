<h1 align="center">Drone Crop Monitoring</h1>
<p align="center">
    <a href="https://github.com/jashanpreet-singh-99/Drone_crop_monitoring_flutter">
    <img src="https://img.shields.io/badge/Flutter-Application-blue?style=for-the-badge&logo=github&logoColor=white" alt="LinkedIn Badge"/>
    </a>
    <a href="https://github.com/jashanpreet-singh-99/Drone_crop_monitoring_web_api">
    <img src="https://img.shields.io/badge/Web-API-blue?style=for-the-badge&logo=github&logoColor=white" alt="LinkedIn Badge"/>
    </a>
    <a href="https://github.com/jashanpreet-singh-99/Drone_Crop_monitoring">
      <img src="https://img.shields.io/badge/CNN-Model-blue?style=for-the-badge&logo=github&logoColor=white" alt="LinkedIn Badge"/>
    </a>
  <br/>
  
  <br/>
  Please take author's permission before usign the code.
</p>
<h2>Overview</h2>
<p align="left">The project comprises three integral components, each serving a distinct purpose in the overall system. The first component entails a sophisticated client-side application designed to efficiently control and monitor the agricultural crops from the clients' perspective. This application offers comprehensive functionality, allowing users to oversee crop conditions, make informed decisions, and optimize farm management processes.

Acting as a crucial intermediary, the second component is a robust Flask API that facilitates seamless communication and data exchange between the 3D simulator and the client application. This API serves as a reliable interface, enabling real-time interaction and data transmission, thereby enhancing the user experience and ensuring smooth integration between the various components of the system.

The third component, a cutting-edge 3D simulator, emulates a real-world farm environment and incorporates a drone equipped with advanced imaging capabilities. This simulated drone autonomously traverses the entire farm, capturing high-resolution images of the crops. These images are subsequently fed into a convolutional neural network (CNN) model, specifically developed for this project. The CNN model, constructed using a custom architecture, plays a pivotal role in detecting and classifying diseases within the crops. It leverages state-of-the-art transfer learning models as benchmarks to ascertain its performance and efficacy.

The intricate synergy among these components empowers the system to revolutionize agricultural practices. Through seamless integration, intelligent data analysis, and advanced imaging technology, the project strives to enhance crop monitoring, enable timely disease detection, and facilitate informed decision-making processes for optimized farm management.</p>

<h2>Client-side Application</h2>
<p>
 The client-side application is meticulously developed using the Flutter framework, ensuring its cross-platform compatibility across multiple devices. Leveraging the versatility of Flutter, the application seamlessly caters to a wide range of operating systems and devices, allowing users to access its features regardless of their preferred platform.

One of the remarkable strengths of the client-side application lies in its optimal utilization of the expansive screen real estate offered by desktop devices. By capitalizing on the available space, the application delivers a rich and immersive user experience, presenting users with comprehensive control and monitoring capabilities for their agricultural crops.

The application boasts two main pages, meticulously designed to cater to the diverse needs of users. Each page is thoughtfully crafted with a user-centric approach, prioritizing usability and intuitive navigation. These pages serve as the primary interfaces through which users can seamlessly interact with the application, empowering them to efficiently manage and monitor their crops with ease.

By harnessing the power of Flutter and strategically capitalizing on the abundant screen real estate of desktop devices, the client-side application offers an unparalleled user experience. It embodies the perfect blend of cross-platform compatibility and intuitive design, elevating agricultural management to new heights and empowering users with the tools they need to maximize productivity and optimize crop yield.
</p>
<ul>
  <li>Add Farm</li>
  <li>Monitor Farm</li>
</ul>
<h3>Add Farm Page</h3>
<p align="center">
  <img src="https://github.com/jashanpreet-singh-99/Drone_crop_monitoring_flutter/blob/main/img_asset/map.png?raw=true" alt="Add farm"/>
</p>
<h4>Usage</h4>
To seamlessly integrate new fields into the system, users can conveniently utilize the intuitive Add Farm page, where they are presented with a comprehensive map interface. Within this interface, users have the ability to precisely define the boundaries of the field by plotting markers that outline its periphery. By placing these markers at strategic locations, users can accurately demarcate the entire field area.

Once all the boundary markers have been meticulously positioned, users can leverage the intuitive "Draw" button to effortlessly calculate the total area covered by the markers on the map. This feature enables users to verify and validate the accuracy of the defined field boundary.

Furthermore, users have the freedom to assign a customized name or label to the newly added field, providing flexibility and personalization. The system then seamlessly integrates this information into the database by simply clicking the "Save" button, ensuring the proper storage and management of field-related data.

On the server side, a sophisticated grid script adeptly processes the marker plots provided by the user. Employing graph theory algorithms, the script partitions the entire farm into multiple grids of equal size. These grids act as pivotal reference points, serving as navigational guides for the drone as it traverses the vast expanse of the farm. This strategic division of the farm into grids enhances the efficiency and precision of the drone's operations, optimizing data collection and monitoring processes.

Moreover, users are afforded the flexibility to add multiple farms within the system. The Monitor Farm page offers a range of controls and functionalities, enabling users to effortlessly deploy or redeploy the drone to different fields with a few simple clicks. This streamlined and user-friendly approach enhances operational efficiency, allowing users to efficiently manage and monitor their farms with ease.

By seamlessly incorporating new fields, leveraging intelligent grid-based navigation, and providing a user-friendly interface, the system empowers users to effortlessly expand their agricultural operations while maintaining optimal control and oversight over their farms.
<h3>Monitor Farm Page</h3>
<p>Once the user selects the specific farm for drone deployment, they gain access to a comprehensive array of controls and drone statistics. The user interface presents a range of meticulously designed controls, empowering the user with seamless command over the drone's operations. These controls encompass three main functionalities:-</p>
<ul>
  <li>Deploy Drone</li>
  <p>Utilizing this intuitive button, users can seamlessly deploy the drone within the currently opened farm, initiating an efficient data gathering process with precision and ease.</p>
  <li>Stall Drone</li>
  <p>Upon deploying the drone, a stall button functionality is incorporated, empowering users to halt the drone at specified positions. This feature facilitates a detailed examination of the images captured by the drone, enabling users to closely analyze the agricultural landscape. Furthermore, manual controls are made available, granting users the ability to exert direct control over the drone's movements through the utilization of the primary drone controller. This comprehensive functionality enhances user engagement and offers a seamless experience in maneuvering the drone for precise observation and analysis.</p>
  <li>Abort Drone</li>
  <p>The "Abort Drone" button initiates an immediate cessation of the drone's ongoing flight plan, directing it to return promptly to the designated charging dock. This functionality serves to ensure a swift and secure retrieval of the drone, enabling subsequent redeployment if deemed necessary.</p>
 </ul>
<p align="center">
  <img src="https://github.com/jashanpreet-singh-99/Drone_crop_monitoring_flutter/blob/main/img_asset/drone_stat.png?raw=true" alt="Drone Stats"/>
</p>
<p>The comprehensive top control panel depicted in the figure above provides users with a holistic view of the drone's status and crucial farm-related information. This centralized interface serves as a valuable resource for monitoring and managing the drone's operations in real-time.

Within the control panel, users can readily access pertinent data, including the current altitude of the drone, measured in feet or meters, ensuring precise monitoring of its positioning. The speed of the blades, presented in revolutions per minute (RPM), allows users to gauge the propulsion efficiency and overall performance of the drone.

To ensure uninterrupted drone operations, the control panel displays essential battery statistics, providing users with insights into the current battery level and estimated remaining flight time. This information enables proactive planning and prevents unexpected interruptions during critical farm monitoring activities.

Moreover, the control panel showcases the current grid identifier of the farm, streamlining the identification and tracking of specific farm areas. Users can easily navigate and focus on different sections of the farm using this reference point.

Crucial to the agricultural monitoring process, the control panel also presents the diseased percentage of the field, offering a comprehensive assessment of the crop's health status. This valuable metric aids in identifying potential disease outbreaks and facilitates timely intervention to mitigate crop losses.

Additionally, the total coverage rate, another key metric displayed on the control panel, indicates the extent to which the farm has been surveyed by the drone. This information helps users track the progress of data collection and ensures comprehensive coverage of the entire farm area.

In addition to the above features, the control panel offers additional functionalities, such as the ability to delete farms that are no longer in operation and the option to rename existing farms. These features enhance the flexibility and customization capabilities of the system, empowering users to adapt and manage their farm portfolios efficiently.

By providing a comprehensive array of real-time information and valuable functionalities, the top control panel exemplifies the project's commitment to empowering users with a sophisticated and intuitive interface for seamless drone management and optimized farm monitoring.</p>

<h2>Flask Web API</h2>

<h2>3D Simulator</h2>
