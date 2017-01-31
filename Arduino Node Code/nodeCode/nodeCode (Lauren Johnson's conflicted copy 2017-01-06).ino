/*
XBee Arduino - Motesquito Code:
Current known bugs and issues:
- If anchors disappear from a mobile nodes anchor address list, the node will continue to 
  ping an anchor which it cannot receive a response from. This will cause the maximum response
  wait time to incur every cycle, slowly increasing delay time between readings.
*/

#include "XBee.h"
#include "TimerOne.h"

// modes:
#define MOBILE_NODE 1
#define ANCHOR_NODE 0
// anchor list parameters:
#define MAX_LEN 15
#define ANCHOR_SEARCH_FREQ 15  // number of minutes anchors are searched for
#define LAGTIME 10

// create the XBee object
XBee xbee = XBee();
ZBRxResponse rx;
ZBTxRequest tx;

// mode variable
int mode = ANCHOR_NODE;

int delay_time_ms = 1000;

// anchor list variables
long addr_list[MAX_LEN];
int sizeOfList = 0;
int timesCalled = ANCHOR_SEARCH_FREQ;  // set to max number of times called to get initial list. Callback function will reset this value to 0.
int i = 0;  // increment variable
uint8_t mobilePayload[50];  // packet for coordinator to send to matlab for processing
uint8_t myAddr[4];  // self address variable

void setup() {
  pinMode(13, OUTPUT);  // LED Pin
  pinMode(2,INPUT);

  Serial.begin(9600);
  xbee.setSerial(Serial);
  
  Timer1.initialize(); // set a timer of length second - this code breaks analogWrite on digital pins 9 and 10

  // get initial mode setting and query for intial anchor list
  if(digitalRead(2)) {
    Serial.println("Mobile Mode");
    delay(1000);  // give the XBee time to connect to the coordinator
    Timer1.attachInterrupt( timerISR ); // attach the service routine here
    anchorSearch();
    mode = MOBILE_NODE;
  }
  else {
    mode = ANCHOR_NODE;
    Serial.println("Anchor Mode");
  }
  
}

void loop() {  
  digitalWrite(13,LOW); // Set reception indication LED low
   // set state of device
  if(digitalRead(2)) {
    if(mode != MOBILE_NODE) {
      mode = MOBILE_NODE;
      Timer1.attachInterrupt( timerISR ); // attach the service routine here
    }
  }
  else {
    if(mode != ANCHOR_NODE) {
      mode = ANCHOR_NODE;
      Timer1.attachInterrupt( timerISR );  // remove anchor searching service routine
    }
  }
    
  switch(mode) {
    case ANCHOR_NODE:
      receiveAnchorPackets(delay_time_ms);
    break;
    case MOBILE_NODE:
      getRSSIFromAnchors();  // poll each anchor node in list for rssi readings and send them to coordinator
      // Search for anchors if enough ticks have passed
      if(timesCalled >= ANCHOR_SEARCH_FREQ) {
        anchorSearch();
        // give time to receive anchor responses
        int currentTime = millis();
        while((millis() - currentTime) < delay_time_ms*2) {
          receiveMobilePackets(delay_time_ms);
        }
        
      }
      receiveMobilePackets(delay_time_ms);
      delay(1000);
    break;  
  }
}

/* Get RSSI function
Received Signal Strength. This command reports the received signal strength of the
last received RF data packet. The DB command only indicates the signal strength of the
last hop. It does not provide an accurate quality measurement for a multihop link. DB can
be set to 0 to clear it. The DB command value is measured in -dBm. For example if DB
returns 0x50, then the RSSI of the last packet received was
-80dBm. As of 2x6x firmware, the DB command value is also updated when an APS
acknowledgment is received.
*/
char getRSSI()
{
  char rssi = 0xFF;
  uint8_t dbCmd[] = {'D','B'};
  AtCommandRequest atRequest = AtCommandRequest(dbCmd);
  AtCommandResponse atResponse = AtCommandResponse();
  atRequest.setCommand(dbCmd);
  xbee.send(atRequest);
  if (xbee.readPacket(5000)) {
    if (xbee.getResponse().getApiId() == AT_COMMAND_RESPONSE) {
      xbee.getResponse().getAtCommandResponse(atResponse);
      if (atResponse.isOk()) {
        //Serial.println("is OK");
        if (atResponse.getValueLength() > 0) {
          for (int i = 0; i < atResponse.getValueLength(); i++) {
            rssi = atResponse.getValue()[i];
          }
        }
      }
      else {
        //Command return error code
        atResponse.getStatus();
      }
    }
    else {
      // Expected AT response but got
      xbee.getResponse().getApiId();
    }
  }
  else {
    if (xbee.getResponse().isError()) {
      // Error reading packet.  Error code:
      xbee.getResponse().getErrorCode();
    }
    else {
      //No response from radio
    }
  }
  //Serial.print("RSSI Value is: ");
  //Serial.println(rssi,HEX);
  return rssi; 
}


void anchorSearch()
{
  timesCalled++;
  if(timesCalled > ANCHOR_SEARCH_FREQ) {
    timesCalled = 0;
    // Search for anchor nodes
    uint8_t payload[] = { 0xEE };
    tx.setAddress16(0xFFFE);
    tx.setFrameId(0x00);
    tx.setOption(0x00);
    tx.setPayload(payload);
    tx.setPayloadLength(sizeof(payload));
    tx.setAddress64(0xFFFF);
    xbee.send(tx);
  }
}

void timerISR()
{
  timesCalled++;
}

// Function to return lower portion of SL (Serial Number / MAC)
void getSL(uint8_t* addr)
{
  //uint8_t addr[4];
  uint8_t slCmd[] = {'S','L'};
  AtCommandRequest atRequest = AtCommandRequest(slCmd);
  AtCommandResponse atResponse = AtCommandResponse();
  atRequest.setCommand(slCmd);
  xbee.send(atRequest);
  if (xbee.readPacket(5000)) {
    if (xbee.getResponse().getApiId() == AT_COMMAND_RESPONSE) {
      xbee.getResponse().getAtCommandResponse(atResponse);
      if (atResponse.isOk()) {
        //Serial.println("is OK");
        if (atResponse.getValueLength() > 0) {
          for (int i = 0; i < atResponse.getValueLength(); i++) {
            addr[i] = atResponse.getValue()[i];
          }
        }
      }
      else {
        //Command return error code
        atResponse.getStatus();
      }
    }
    else {
      // Expected AT response but got
      xbee.getResponse().getApiId();
    }
  }
  else {
    if (xbee.getResponse().isError()) {
      // Error reading packet.  Error code:
      xbee.getResponse().getErrorCode();
    }
    else {
      //No response from radio
    }
  }
}

void receiveMobilePackets(int delayTime) {
  // get received packets:
  xbee.readPacket(delayTime);     
  if (xbee.getResponse().isAvailable()) {
    // got something
    //Serial.println("Packet Received!");
    if (xbee.getResponse().getApiId() == ZB_RX_RESPONSE) {
      // got a zb rx packet
      digitalWrite(13,HIGH);
      // now fill our zb rx class
      xbee.getResponse().getZBRxResponse(rx);
      if(rx.getFrameData()[rx.getDataOffset()] == 0xEF) { // Anchor Search Response
        long tmp_addr = (long)rx.getRemoteAddress64().getLsb();
        // Search to see if address is already in list
        int hit = 0;  // search variable
        for(int j = 0; j < sizeOfList; j++) {
          if(addr_list[j] == tmp_addr)
            hit = 1;
        }
        // Add new address to list
        if(hit != 1) {
          if(sizeOfList <= MAX_LEN) {
            sizeOfList++;          
            addr_list[sizeOfList-1] = (long)rx.getRemoteAddress64().getLsb();
          }
        }
        //Serial.println("Adding to anchor list!");
        //Serial.println(addr_list[sizeOfList-1],HEX);
      }
      else if(rx.getFrameData()[rx.getDataOffset()] == 0xFD) { // Mobile Polling Frequency
        delay_time_ms = rx.getFrameData()[rx.getDataOffset() + 1];
        //Serial.println("Adding to anchor list!");
        //Serial.println(addr_list[sizeOfList-1],HEX);
      }
    }
  }
}

void receiveAnchorPackets(int delayTime) {
  // Anchor nodes only respond to RSSI Requests and Anchor Search Messages
  xbee.readPacket();     
  if (xbee.getResponse().isAvailable()) {
    // got something
    if (xbee.getResponse().getApiId() == ZB_RX_RESPONSE) {
      // got a zb rx packet
      digitalWrite(13,HIGH);
      // now fill our zb rx class
      xbee.getResponse().getZBRxResponse(rx);
      if(rx.getFrameData()[rx.getDataOffset()] == 0xFE) { // RSSI Request
        uint8_t rssi = getRSSI();
        if(rssi != 0xFF) {
          uint8_t payload[] = { 0xDB, rssi };  // RSSI response
          tx.setAddress16(0xFFFE);
          tx.setFrameId(0x00);
          tx.setOption(0x00);
          tx.setPayload(payload);
          tx.setPayloadLength(2);
          tx.setBroadcastRadius(1);
          tx.setAddress64(rx.getRemoteAddress64());
          xbee.send(tx); 
        }  
      }
      else if(rx.getFrameData()[rx.getDataOffset()] == 0xEE) { // Anchor Search Message
        uint8_t payload[] = { 0xEF };  // Anchor response
        tx.setAddress16(0xFFFE);
        tx.setFrameId(0x00);
        tx.setOption(0x00);
        tx.setPayload(payload);
        tx.setPayloadLength(1);
        tx.setAddress64(rx.getRemoteAddress64());
        xbee.send(tx);   
      }
    }
  }
}

void getRSSIFromAnchors()
{// transmit to each anchor node on list
  int transmitFlag = 0;  // flag to indicate if data was received and transmission to coordinator is possible
  if(sizeOfList > 0) {  // if anchor nodes are available to transmit to...
    int j = 0;  // j only increments when a packet responds
    for(i = 0; i < sizeOfList; i++) {
      delay(LAGTIME);
      // Create Packet to request RSSI from Anchor i ...............................................
      uint8_t payload[] = { 0xFE };  // RSSI Request
      XBeeAddress64 addr64 = XBeeAddress64(0x0013A200, addr_list[i]);
      tx.setAddress16(0xFFFE);
      tx.setFrameId(0x00);
      tx.setOption(0x00);
      tx.setBroadcastRadius(1);  // search only one hop away
      tx.setPayload(payload);
      tx.setPayloadLength(sizeof(payload));
      tx.setAddress64(addr64);
      // Trasmit RSSI Request Packet................................................................
      xbee.send(tx);
      // Wait for response..........................................................................
      xbee.readPacket(delay_time_ms);  // wait for packet response up to X ms     
      if (xbee.getResponse().isAvailable()) {
        // got something
        if (xbee.getResponse().getApiId() == ZB_RX_RESPONSE) {
          // got a zb rx packet
          digitalWrite(13,HIGH);
          // now fill our zb rx class
          xbee.getResponse().getZBRxResponse(rx);
          if(rx.getFrameData()[rx.getDataOffset()] == 0xDB) { // RSSI Response
            // add data to packet to send to coordinator
            getSL(myAddr);
            mobilePayload[(j)*5 + 6] = rx.getFrameData()[rx.getDataOffset()+1];  // second bit of payload contains RSSI value
            mobilePayload[(j)*5 + 7] = (long)(rx.getRemoteAddress64().getLsb() >> 24) & 0xFF;
            mobilePayload[(j)*5 + 8] = (long)(rx.getRemoteAddress64().getLsb() >> 16) & 0xFF;
    	    mobilePayload[(j)*5 + 9] = (long)(rx.getRemoteAddress64().getLsb() >> 8) & 0xFF;
    	    mobilePayload[(j)*5 + 10] = (long)rx.getRemoteAddress64().getLsb() & 0xFF;
            j++;
            transmitFlag = 1;
          }
        }
      }
    }
    // Transmit packet to coordinator after transmitting to each node...................................
    if(transmitFlag) {
      mobilePayload[0] = 0xF0;  // Coordinator RSSI packet type
      mobilePayload[1] = ((j)*5 + 6) - 2;  // payload length after packet identifier and this byte
      mobilePayload[2] = myAddr[0]; 
      mobilePayload[3] = myAddr[1]; 
      mobilePayload[4] = myAddr[2]; 
      mobilePayload[5] = myAddr[3]; 
      tx.setAddress16(0xFFFE);
      tx.setFrameId(0x00);
      tx.setOption(0x00);
      tx.setPayload(mobilePayload);
      tx.setPayloadLength((j)*5 + 6);  // array length
      tx.setAddress64(0x0000000000000000);  // set coordinator address
      xbee.send(tx); 
    }
  }
}
  
