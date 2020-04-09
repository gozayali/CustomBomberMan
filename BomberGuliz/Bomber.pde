class Bomber {
  PImage img, img_bw;
  int walkX, walkY, speed;
  int x, y, bombPwr, maxBomb;
  long dieTime;
  ArrayList<Bomb> bombs;
  ArrayList<Bomb> patlaklar;
  boolean[] yonler;
  boolean kur;
  int les;
  String name; 

  public Bomber(int _x, int _y, String _name) {
    name=_name;
    if (name.equalsIgnoreCase("ali")) {
      img=ali.copy();
      img_bw=ali_bw.copy();
    } else {
      img=guliz.copy();
      img_bw=guliz_bw.copy();
    }
    walkX= (_x*placePxl)+placePxl/2;
    walkY=(_y*placePxl)+placePxl/2;
    speed=1;
    maxBomb=1;
    bombPwr=1;
    bombs=new ArrayList<Bomb>();
    patlaklar=new ArrayList<Bomb>();
    yonler= new boolean[]{false, false, false, false};
    dieTime=0;
    les=0;
    kur=false;
  }

  void ciz() { 

    for (Bomb b : bombs) {
      if (b.patladi)
        patlaklar.add(b);
      else
        b.ciz();
    }
    for (Bomb b : patlaklar) {
      bombs.remove(b);
    }
    patlaklar.clear();
    if (dieTime==0) {
      move();
      image(img, walkX-(img.width)/2, walkY-(img.height)/2);
    } else if (dieTime+2000>millis()) {
      image(img_bw, walkX-(img_bw.width)/2, walkY-(img_bw.height)/2);
    } else {
      image(rip, walkX-(rip.width)/2, walkY-(rip.height)/2);
    }
  }

  void move() {
    if (kur) {
      addBomb();
    }
    if (yonler[0] && movable(0)) {
      walkX-=speed;
    }
    if (yonler[1] && movable(1)) {
      walkX+=speed;
    }
    if (yonler[2] && movable(2)) {
      walkY-=speed;
    }
    if (yonler[3] && movable(3)) {
      walkY+=speed;
    }
    toLoc();
  }

  void addBomb() {
    if (area[x][y]!=BOMB && bombs.size()<maxBomb && bombs.size()>=0 ) {
      bombs.add(new Bomb(x, y, bombPwr, millis(), name));
    }
  }

  void toLoc() {
    x=walkX/placePxl;
    y=walkY/placePxl;
    if (area[x][y]==POWER) {
      vol_power.play(0);
      bombPwr++;
      area[x][y]=EMPTY;
    }
    if (area[x][y]==EXTRA) {
      vol_extra.play(0);
      maxBomb++;
      area[x][y]=EMPTY;
    }
  }

  boolean movable(int yon) {
    int tempX1=walkX-(img.width)/2;
    int tempY1=walkY-(img.height)/2;
    int tempX2=walkX+(img.width)/2;
    int tempY2=walkY+(img.height)/2;
    switch(yon) {
    case 0:
      tempX1-=speed;
      tempX2-=speed;
      break;
    case 1:
      tempX1+=speed;
      tempX2+=speed;
      break;
    case 2:
      tempY1-=speed;
      tempY2-=speed;
      break;
    case 3:
      tempY1+=speed;
      tempY2+=speed;
      break;
    }

    if (tempX1>=0  && tempY1>=0  && tempX2<width && tempY2<height) {
      int ax1= (tempX1)/placePxl;
      int ay1= (tempY1)/placePxl;
      int ax2= (tempX2-1)/placePxl;
      int ay2= (tempY2-1)/placePxl;
      if (movableArea(ax1, ay1) && movableArea(ax1, ay2)&& movableArea(ax2, ay1)&&movableArea(ax2, ay2)) {       
        return true;
      } else if ( ( ax2<xSize && ay1>=0 && area[ax2][ay1]==BOMB) || 
        ( ax2<xSize && ay2<ySize && area[ax2][ay2]==BOMB) || 
        ( ax1>=0 && ay1>=0 && area[ax1][ay1]==BOMB) || 
        ( ax1>=0 && ay2<ySize &&area[ax1][ay2]==BOMB) ) {    //bombadan kaçma
        if ( yon==0 &&  ((movableArea(x-1, ay1) && movableArea(x-1, ay2)) || ( movableArea(ax1, ay1) && movableArea(ax1, ay2)))) {
          return true;
        } else if ( yon==1 &&  ((movableArea(x+1, ay1) && movableArea(x+1, ay2)) || (movableArea(ax2, ay1) && movableArea(ax2, ay2)) )) {
          return true;
        } else if ( yon==2 && (( movableArea(ax1, y-1) && movableArea(ax2, y-1)) || (movableArea(ax1, ay1) && movableArea(ax2, ay1)) )) {
          return true;
        } else if ( yon==3 && ((movableArea(ax1, y+1) && movableArea(ax2, y+1)) || (movableArea(ax1, ay2) && movableArea(ax2, ay2))  )) {
          return true;
        }
      }
    }
    return false;
  }
}