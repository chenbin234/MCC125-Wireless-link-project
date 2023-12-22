# MCC125-Wireless-link-project

## 1 Introduction
This is a course project,we need to demonstrate a simplex transmission of data (text, or picture or other file of your choice) over a distance of 100 m using your own designed and assembled hardware. You will construct and use your own software to modulate the carrier in the transmitter, to detect your message in the receiver and to correct the hardware impairments such as frequency offset, phase offset, timing synchronization, etc. To successfully complete the course on time, you will need to meet a certain deadlines, as for example submitting your PCB designs.

## 2 Hardware Design

### 2.1 Transmitter

![transmitter](00_SystemDesign/Transmitter.jpg)

### 2.2 Receiver

![transmitter](00_SystemDesign/Receiver.jpg)



## 3 Software Design

### 3.1 Tranmitter & Receiver

![transmitter_block_diagram](images/transmitter_block_diagram.png)

![receiver_block_diagram](images/receiver_block_diagram.png)

### 3.2 System Improvement Attempt

#### 3.2.1 Neural network model embedded in the receiver

![receiver_new_design](images/receiver_new_design.png)

#### 3.2.2 Three main steps

![idea_Diagram.drawio](images/idea_Diagram.drawio.png)

#### 3.2.3 Which data to collect

![where_to_collect_data](images/where_to_collect_data.png)

#### 3.2.4 How to automatically collect data

![udp_connection_Diagram](images/udp_connection_Diagram.png)

#### 3.2.5 Choose transformer architecture

<img src="images/transformer%20(2).png" alt="transformer (2)" style="zoom:33%;" />

## 4 Result

The detailed solution and result can be found in the final report (in fold /04_Submition)
