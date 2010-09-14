// You will need to customize these settings
// This script assumes that the ethernet shield has already been started
byte smtp_server[] = {0, 0, 0, 0};
int port = 25;
String username = ""; // Base 64 encoded
String password = ""; // Base 64 encoded
String from_email = "";
String to_email = ""; // Try sending to a SMS address.

Client smtp_client(smtp_server, port);

void smtp_startConnection(){
  //Serial.println("Connecting (SMTP)...");
  
  if(smtp_client.connect()){
    //Serial.println("Connected");
  }else{
    //Serial.println("Connection failed");
  }
}

void smtp_stopConnection(){
    //Serial.println("Disconnecting (SMTP)");

    //Serial.println();

    smtp_client.stop();
}

void smtp_send(String message){
  smtp_send_message("HELO\r\n");
  smtp_send_message("AUTH LOGIN\r\n");
  smtp_send_message(username);
  smtp_send_message("\r\n");
  smtp_send_message(password);
  smtp_send_message("\r\n");
  smtp_send_message("MAIL FROM:");
  smtp_send_message(from_email);
  smtp_send_message("\r\n");
  smtp_send_message("RCPT TO:");
  smtp_send_message(to_email);
  smtp_send_message("\r\n");
  smtp_send_message("DATA");
  smtp_send_message("\r\n");
  smtp_send_message(message.substring(1, message.length()));
  smtp_send_message("\r\n");
  smtp_send_message("."); 
  smtp_send_message("\r\n");
  smtp_send_message("QUIT\r\n");
  smtp_read();
}

void smtp_send_message(String message){
  smtp_read();
  smtp_client.print(message);
  //Serial.print(message);
  delay(1000);
}
 
void smtp_read(){
    while(smtp_client.available()){
    char c = smtp_client.read();
    //Serial.print(c);
  }
}
