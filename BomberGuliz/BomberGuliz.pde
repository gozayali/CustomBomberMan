import ddf.minim.*;
import controlP5.*;

ControlP5 control;
RadioButton rb;
int cb_index=0;
int count = 0;

static final int BOMB = -1;
static final int EMPTY = 0;
static final int WOOD = 1;
static final int ROCK = 2;
static final int POWER = 3;
static final int EXTRA = 4;
static final int HIDDEN_POWER = 5;
static final int HIDDEN_EXTRA = 6;

int placePxl, xSize, ySize;
int [][] area; 

PFont font;
PImage bomb, bomb2, pwr, extra, flame, flame2;
PImage wood, rock, empty, canavar, canavar_bw;
PImage ali, ali_bw, guliz, guliz_bw, rip;
PImage pwr_mini, cnt_mini, rip_mini, canavar_mini, ali_buyuk, guliz_buyuk;

AudioPlayer vol_tema, vol_timer, vol_bomb, vol_power, vol_extra, vol_torch, vol_death;

int extraCnt, pwrCnt, canavarCnt, liveCnt;

ArrayList<Canavar> canavarList;
ArrayList<Bomber> bomberList;

String message="";
long messageTime=0;
boolean bulusma=false;
boolean startGame=false;

void setup() {
  size(1170, 670);
  font=createFont("arial", 20);
  placePxl=50;
  xSize=21;
  ySize=11;
  extraCnt=4;
  pwrCnt=4;
  canavarCnt=10;

  vol_tema= new Minim(this).loadFile("ses/renk.mp3");
  vol_extra= new Minim(this).loadFile("ses/extra.wav");
  vol_power= new Minim(this).loadFile("ses/power.wav");
  vol_timer= new Minim(this).loadFile("ses/timer.wav");
  vol_bomb= new Minim(this).loadFile("ses/bomb.wav");
  vol_torch= new Minim(this).loadFile("ses/torch.wav");
  vol_death= new Minim(this).loadFile("ses/death.wav");

  resimleriGetir(50);

  vol_tema.setLoopPoints(2500, 39000);
  vol_tema.loop();
  control();
}

void GameSetup() {

  surface.setSize(placePxl*xSize, placePxl*ySize+100);

  resimleriGetir(placePxl);

  bomberList=new ArrayList<Bomber>();
  bomberList.add( new Bomber(0, 0, "guliz"));
  bomberList.add(new Bomber (xSize-1, ySize-1, "ali"));
  liveCnt=bomberList.size();

  canavarList=new ArrayList<Canavar>();
  prepareArea();
}

void resimleriGetir(int pxl) {
  wood = loadImage("resim/wood.png");
  rock = loadImage("resim/rock.png");
  bomb = loadImage("resim/bomb.png");
  bomb2 = loadImage("resim/bomb2.png");
  flame = loadImage("resim/flame.png");
  flame2 = loadImage("resim/flame2.png");
  empty = loadImage("resim/empty.png");
  pwr = loadImage("resim/pwr.png");
  extra = loadImage("resim/extra.png");
  ali = loadImage("resim/ali.png");
  ali_bw = loadImage("resim/ali_bw.png");
  guliz = loadImage("resim/guliz.png");
  guliz_bw = loadImage("resim/guliz_bw.png");
  rip = loadImage("resim/rip.png");
  canavar = loadImage("resim/canavar.png");
  canavar_bw = loadImage("resim/canavar_bw.png");

  int mini_size=15;
  pwr_mini=flame.copy();
  pwr_mini.resize(mini_size, mini_size);
  cnt_mini=bomb.copy();
  cnt_mini.resize(mini_size, mini_size);
  rip_mini=rip.copy();
  rip_mini.resize(20, 20);
  canavar_mini=canavar.copy();
  canavar_mini.resize(mini_size, mini_size);

  ali_buyuk=ali.copy();
  ali_buyuk.resize(90, 90);
  guliz_buyuk=guliz.copy();
  guliz_buyuk.resize(90, 90);

  wood.resize(pxl, pxl);
  rock.resize(pxl, pxl);
  bomb.resize(pxl, pxl);
  bomb2.resize(pxl, pxl);
  flame.resize(pxl, pxl);
  flame2.resize(pxl, pxl);
  empty.resize(pxl, pxl);
  pwr.resize(pxl, pxl);
  extra.resize(pxl, pxl);
  ali.resize(0, pxl*4/5);
  ali_bw.resize(0, pxl*4/5);
  guliz.resize(0, pxl*4/5);
  guliz_bw.resize(0, pxl*4/5);
  rip.resize(pxl, pxl);
  canavar.resize(pxl, pxl);
  canavar_bw.resize(pxl, pxl);
}

void draw() {

  background(0);

  if (startGame) {
    areaCiz();
    for (Bomber b : bomberList) {
      b.ciz();
    }
    ArrayList<Canavar> olenler=new ArrayList<Canavar>();
    for (Canavar c : canavarList) {
      c.ciz();
      if (c.dieTime>0 && millis()-c.dieTime>2000)
        olenler.add(c);
    }
    for (Canavar c : olenler) {
      canavarList.remove(c);
    }

    checkResult();
    gostergeCiz();
  } else {
    girisEkraniCiz();
  }
}

void checkResult() {
  int temp=0;
  for (Bomber bomber : bomberList) {
    if (bomber.dieTime==0)
      temp++;
  }
  liveCnt=temp;

  if (liveCnt==0) {
    message="OYUN BİTTİ, KAYBETTİNİZ..";
  } else if (canavarList.size()==0) {
    if (!bulusma) {
      message="ŞİMDİ BULUŞMA ZAMANIII";
      if (bomberList.get(0).x==bomberList.get(1).x &&
        bomberList.get(0).y==bomberList.get(1).y) {
        bulusma=true;
      }
    } else {
      if (liveCnt==2 && messageTime==0)
        message="...SONSUZA KADAR MUTLU YAŞADILAR...";
      else {
        if (messageTime==0) {
          message="SEVGİLERİ ONLARIN YAŞAMA GÜCÜYDÜ..";
          messageTime=millis();
        } else if ( millis()>messageTime+6000 ) {
          messageTime=0;
        } else if ( millis()>messageTime+3000 ) {
          for (Bomber bomber : bomberList) {
            bomber.dieTime=0;
          }
          message="VE HERŞEYİ İYİLEŞTİRİRDİ..";
        }
      }
    }
  }
}
void girisEkraniCiz() {

  PImage bg= rock.copy();
  bg.resize(width, height);
  background(bg);

  textAlign(CENTER, CENTER);

  fill(200, 220, 0);
  rect(50, 50, width/2-60, 380);
  fill(250);
  rect(200, 90, width/2-360, 30);        
  textSize(20);
  fill(220, 0, 0);
  text("KONTROLLER", width/4+25, 103); 

  image(guliz_buyuk, 80, 60);
  image(ali_buyuk, width/2-40-ali_buyuk.width, 60);

  fill(250);
  rect(110, 170, 30, 30);
  rect(110, 220, 30, 30);
  rect(110, 270, 30, 30);    
  rect(110, 320, 30, 30);
  rect(65, 370, 75, 30);  

  rect(480, 170, 30, 30);
  rect(480, 220, 30, 30);
  rect(480, 270, 30, 30); 
  rect(480, 320, 30, 30); 
  rect(480, 370, 80, 30);

  fill(0);
  triangle(490, 180, 490, 190, 500, 185);
  triangle(490, 235, 500, 230, 500, 240);
  triangle(490, 290, 500, 290, 495, 280);
  triangle(490, 330, 500, 330, 495, 340);

  triangle(503, 390, 505, 388, 505, 392);
  line(505, 390, 550, 390);
  line(550, 390, 550, 380);
  textSize(12);
  text("ENTER", 530, 380);

  textSize(20);
  text("D", 125, 182);
  text("A", 125, 232);
  text("W", 125, 282);
  text("S", 125, 332);
  line(75, 395, 130, 395);
  line(75, 390, 75, 395);
  line(130, 390, 130, 395);
  textSize(12);
  text("SPACE", 103, 385);

  textSize(13);
  text("SAĞA GİDER", width/4+25, 180);
  text("SOLA GİDER", width/4+25, 230);
  text("YUKARI GİDER", width/4+25, 280);
  text("AŞAĞI GİDER", width/4+25, 330);
  text("BOMBA BIRAKIR", width/4+25, 380);


  fill(200, 220, 0);
  rect(width/2+10, 50, width/2-60, 380);
  fill(250);
  rect(width/2+20, 60, width/2-80, 30);
  rect(width/2+20, 190, width/2-80, 30);

  textSize(20);
  fill(220, 0, 0);
  text("BONUSLAR", width*3/4-20, 75); 
  text("ENGELLER", width*3/4-20, 205);

  rock.resize(50, 50);
  wood.resize(50, 50);

  image(extra, width/2+30, 120-extra.height/2);
  image(pwr, width-70-pwr.width, 120-pwr.height/2);

  image(rock, width/2+30, 265-rock.height/2);
  image(wood, width/2+30, 355-wood.height/2);
  fill(0);
  textSize(13);
  text("EXTRA BOMBA                                EXTRA PATLAMA ALANI", width*3/4-20, 120);
  text("DUVAR ENGELİ\nPATLAMAZ, ÇATLAMAZ, MİS GİBİ KORUNAKLARDIR", width*3/4, 265);
  text("SANDIK ENGELİ\nBOMBA İLE PATLATILABİLİR, BAZILARININ İÇİNDEN BONUS ÇIKAR", width*3/4, 355);


  fill(200, 220, 0);
  rect(50, 450, width-100, height-500);

  fill(250);
  rect(60, 460, width-120, 30);
  textSize(20);
  fill(220, 0, 0);
  text("HARİTA SEÇİMİ", width/2, 475); 

  if ((count/50)%2==0)
    fill(120, 250, 250);
  else
    fill(255, 255, 0);        

  rect(60, 500, width/2-70, height-560);  
  fill(0); 
  textSize(13);
  text("BomberGüliz oyununa başlamak için;\n\n* Önce haritanı seç *\n* Sonra 'AYARLA' butonuna bas *\n!!! Bunları yaparken ZİBİDİLİK YAPMA !!!", width/4+25, height/2+220);  
  count++;
}

void control() {
  if (control!=null)
    control.hide();
  surface.setSize(1170, 670);

  control = new ControlP5(this);

  rb= control.addRadioButton("rb").setPosition(width*3/4-270, 500).setSize(50, 50).setItemsPerRow(3).setSpacingColumn(120)
    .setColorBackground(color(20))
    .setColorForeground(color(80))
    .setColorActive(color(200,0, 0))
    .setColorLabel(color(20))
    .setNoneSelectedAllowed(false) 
    .addItem("KÜÇÜK\n(23x11)", 50)
    .addItem(" ORTA\n(29x15)", 40)
    .addItem("BÜYÜK\n(39x19)", 30);    
  for (Toggle t : rb.getItems()) {
    t.setFont(font);
    t.getCaptionLabel().setColorBackground(color(80,80));
    t.getCaptionLabel().getStyle().moveMargin(-14, 0, -5, 0);
    t.getCaptionLabel().getStyle().movePadding(5, 0, 5, 5);
    t.getCaptionLabel().getStyle().backgroundWidth = 80;
    t.getCaptionLabel().getStyle().backgroundHeight = 40;
  }
  rb.activate(cb_index);
  control.addBang("AYARLA").setPosition(width*3/4-270,height-110).setSize(480, 50).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setFont(font);
}

public void controlEvent(ControlEvent e) {
  if (e.isFrom("rb")) {
    placePxl=int(e.getValue());
  } else if (e.getController().getName().equals("AYARLA")) { // Oyun ayarları seçimi
    switch(placePxl) {
    case 50:
      xSize=23;
      ySize=11;
      cb_index=0;
      break;
    case 40:
      xSize=29;
      ySize=15;
      cb_index=1;
      break;
    case 30:
      xSize=39;
      ySize=19;
      cb_index=2;
      break;
    }

    control.hide();   
    canavarCnt=(xSize*ySize-32)/19;
    extraCnt=xSize*ySize/50;
    pwrCnt=extraCnt;
    println("C:"+canavarCnt+" B:"+extraCnt );
    message="";
    messageTime=0;
    bulusma=false;
    GameSetup();    
    startGame=true;
  }
}


void prepareArea() {
  IntList woodsX= new IntList();
  IntList woodsY= new IntList();

  IntList emptyX= new IntList();
  IntList emptyY= new IntList();

  area=new int[xSize][ySize];
  for (int x=0; x<xSize; x++)
    for (int y=0; y<ySize; y++) {
      if (x%2==1 && y%2==1)
        area[x][y]=ROCK;
      else if (x+y<2 || x+y>=xSize+ySize-3 ) { //ilk hareket garantisi
        area[x][y]=EMPTY;
      } else {
        area[x][y]= (int)(random(3)%2);
        if (area[x][y]==WOOD) {
          woodsX.append(x);
          woodsY.append(y);
        } else if ( (x>=5 && y>=5) && (x<=xSize-5 && y<=ySize-5) ) {
          emptyX.append(x);
          emptyY.append(y);
        }
      }
    }
  area[0][2]=WOOD;
  area[2][0]=WOOD;
  area[xSize-3][ySize-1]=WOOD;
  area[xSize-1][ySize-3]=WOOD;
  if ((woodsX.size()<pwrCnt+extraCnt)||emptyX.size()<canavarCnt) {
    prepareArea();
  } else {
    for (int i=0; i<pwrCnt; i++) {
      int index= (int)random(woodsX.size());
      area[woodsX.get(index)][woodsY.get(index)]=HIDDEN_POWER;
      woodsX.remove(index);
      woodsY.remove(index);
    }
    for (int i=0; i<extraCnt; i++) {
      int index= (int)random(woodsX.size());
      area[woodsX.get(index)][woodsY.get(index)]=HIDDEN_EXTRA;
      woodsX.remove(index);
      woodsY.remove(index);
    }
    for (int i=0; i<canavarCnt; i++) {
      int index= (int)random(emptyX.size());
      canavarList.add(new Canavar(emptyX.get(index), emptyY.get(index)));
    }
  }
}

void areaCiz() {
  for (int x=0; x<xSize; x++)
    for (int y=0; y<ySize; y++) {
      if (area[x][y]==ROCK) 
        image(rock, x*placePxl, y*placePxl);
      else if (area[x][y]==WOOD)
        image(wood, x*placePxl, y*placePxl);
      else if (area[x][y]==EMPTY)
        image(empty, x*placePxl, y*placePxl);
      else if (area[x][y]==HIDDEN_POWER)
        image(wood, x*placePxl, y*placePxl);
      else if (area[x][y]==HIDDEN_EXTRA)
        image(wood, x*placePxl, y*placePxl);
      else if (area[x][y]==POWER) {
        image(empty, x*placePxl, y*placePxl);
        image(pwr, x*placePxl, y*placePxl);
      } else if (area[x][y]==EXTRA) {
        image(empty, x*placePxl, y*placePxl);
        image(extra, x*placePxl, y*placePxl);
      }
    }
}


void gostergeCiz() {  
  textAlign(LEFT, CENTER);

  textSize(16);
  fill(255, 200, 0);
  text("GÜLİZ", 120, height-85);
  textSize(12);
  fill(255); 
  text("BOMBA GÜCÜ", 120, height-63);
  text("BOMBA SAYISI", 120, height-38);
  text("ALINAN KELLE", 120, height-13);

  image(guliz_buyuk, 5, height-95);
  if (bomberList.get(0).dieTime> 0 && bomberList.get(0).dieTime+2000<millis())
    image(rip_mini, 170, height-95);
  for (int i=0; i<bomberList.get(0).bombPwr; i++) {
    image(pwr_mini, 220+i*(pwr_mini.width+10), height-70);
  }
  for (int i=0; i<bomberList.get(0).maxBomb-bomberList.get(0).bombs.size(); i++) {
    image(cnt_mini, 220+i*(cnt_mini.width+10), height-45);
  }
  image(canavar_mini, 220, height-20);
  text(bomberList.get(0).les, 240, height-13);

  textSize(16);
  fill(255, 200, 0);
  text("ALİ", width-150, height-85);
  fill(255);
  textSize(12);
  text("BOMBA GÜCÜ", width-200, height-63);
  text("BOMBA SAYISI", width-200, height-38);
  text("ALINAN KELLE", width-200, height-13);
  image(ali_buyuk, width-95, height-95);
  if (bomberList.get(1).dieTime> 0 && bomberList.get(1).dieTime+2000<millis())
    image(rip_mini, width-180, height-95);
  for (int i=0; i<bomberList.get(1).bombPwr; i++) {
    image(pwr_mini, width-210-((i+1)*(pwr_mini.width+10)), height-70);
  }
  for (int i=0; i<bomberList.get(1).maxBomb-bomberList.get(1).bombs.size(); i++) {
    image(cnt_mini, width-210-((i+1)*(cnt_mini.width+10)), height-45);
  }
  image(canavar_mini, width-210-(canavar_mini.width+10), height-20);
  text(bomberList.get(1).les, width-250, height-13);

  textSize(13);
  textAlign(CENTER, CENTER);
  fill(255, 20, 10);
  text("ÇIKMAK İÇİN 'DEL' TUŞUNA BASIN", width/2, height-90);
  textSize(10);
  fill(255, 200, 0);
  text("YUKARI", width/2, height-70);
  text("AŞAĞI", width/2, height-55);
  text("SOL", width/2, height-40);
  text("SAĞ", width/2, height-25);
  text("BOMBA", width/2, height-10);

  int uzaklik=50;
  fill(230);
  for (int i=0; i<4; i++) {
    rect(width/2-uzaklik-15, height-76+(i*15), 15, 15);
    rect(width/2+uzaklik, height-76+(i*15), 15, 15);
  }
  rect(width/2-uzaklik-50, height-16, 50, 15);
  rect(width/2+uzaklik, height-16, 50, 15);

  fill(0);
  text("↑", width/2+uzaklik+8, height-70);
  text("↓", width/2+uzaklik+8, height-55);
  text("←", width/2+uzaklik+8, height-40);
  text("→", width/2+uzaklik+8, height-25);
  text("ENTER", width/2+uzaklik+25, height-10);

  text("W", width/2-uzaklik-8, height-70);
  text("S", width/2-uzaklik-8, height-55);
  text("A", width/2-uzaklik-8, height-40);
  text("D", width/2-uzaklik-8, height-25);
  text("SPACE", width/2-uzaklik-25, height-10);


  if (message.length()>0) {
    textSize(15);
    textAlign(CENTER, CENTER);
    fill(255, 0, 0);
    rect(width/4, 0, width/2, 30);
    fill(0);
    rect(width/4+3, 3, width/2-6, 24);
    fill(255);
    text(message, width/2, 13);
  }
}

boolean movableArea(int _x, int _y) {
  if (_x<0 || _y<0 || _x>=xSize || _y>=ySize)
    return false;
  return (area[_x][_y]==EMPTY || area[_x][_y]==EXTRA || area[_x][_y]==POWER );
}

void keyPressed() {
  if (keyCode==DELETE ) {
    startGame=false;
    control();
    resimleriGetir(50);
  }
  if (startGame) {
    if (keyCode==ENTER) {
      bomberList.get(1).kur=true;
    }
    if (keyCode==LEFT ) {
      bomberList.get(1).yonler[0]=true;
    }
    if (keyCode==RIGHT) {
      bomberList.get(1).yonler[1]=true;
    }
    if (keyCode==UP) {
      bomberList.get(1).yonler[2]=true;
    }
    if (keyCode==DOWN) {
      bomberList.get(1).yonler[3]=true;
    }
    if (key==' ') {
      bomberList.get(0).kur=true;
    }
    if (key=='a' || key=='A' ) {
      bomberList.get(0).yonler[0]=true;
    }
    if (key=='d' || key=='D' ) {
      bomberList.get(0).yonler[1]=true;
    }
    if (key=='w' || key=='W' ) {
      bomberList.get(0).yonler[2]=true;
    }
    if (key=='s' || key=='S' ) {
      bomberList.get(0).yonler[3]=true;
    }
  }
}

void keyReleased() {
  if (startGame) {
    if (keyCode==ENTER) {
      bomberList.get(1).kur=false;
    }
    if (keyCode==LEFT ) {
      bomberList.get(1).yonler[0]=false;
    }
    if (keyCode==RIGHT) {
      bomberList.get(1).yonler[1]=false;
    }
    if (keyCode==UP) {
      bomberList.get(1).yonler[2]=false;
    }
    if (keyCode==DOWN) {
      bomberList.get(1).yonler[3]=false;
    }
    if (key==' ') {
      bomberList.get(0).kur=false;
    }
    if (key=='a' || key=='A' ) {
      bomberList.get(0).yonler[0]=false;
    }
    if (key=='d' || key=='D' ) {
      bomberList.get(0).yonler[1]=false;
    }
    if (key=='w' || key=='W' ) {
      bomberList.get(0).yonler[2]=false;
    }
    if (key=='s' || key=='S' ) {
      bomberList.get(0).yonler[3]=false;
    }
  }
}