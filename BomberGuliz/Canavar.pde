class Canavar {
  int walkX, walkY;
  int x, y;
  int speed;
  int yon;
  long hapisCikisi;
  long dieTime;
  public Canavar(int _x, int _y) {
    walkX=(_x*placePxl)+placePxl/2;
    walkY=(_y*placePxl)+placePxl/2;
    speed=1;
    dieTime=0;
    yon=(int)random(4);
    hapisCikisi=0;
  }

  void ciz() {
    if (dieTime==0) {
      move();
      image(canavar, walkX-canavar.width/2, walkY-canavar.height/2);
    } else {
      image(canavar_bw, walkX-canavar_bw.width/2, walkY-canavar_bw.height/2);
    }
  }

  void move() {
    x= walkX/placePxl;
    y= walkY/placePxl;
    if (walkX % placePxl == placePxl/2 && walkY%placePxl==placePxl/2) {
      yonSec();
    }
    if (yon==0 ) {
      walkX-=speed;
    }
    if (yon==1) {
      walkX+=speed;
    }
    if (yon==2) {
      walkY-=speed;
    }
    if (yon==3) {
      walkY+=speed;
    }
    bomberOldur(10);
  }

  void yonSec() {
    boolean[] acikYon= new boolean[]{movableArea(x-1, y), movableArea(x+1, y), movableArea(x, y-1), movableArea(x, y+1)};
    int acikYonSayisi= 0;
    for ( boolean flag : acikYon) {
      if (flag)
        acikYonSayisi++;
    }
    if (acikYonSayisi>0) {
      if (yon<0) {
        if (hapisCikisi==0) {
          hapisCikisi=millis();
        } else if (millis()-hapisCikisi>500) {
          yon=int(random(4));
        }
      }
      if ( yon>=0 && ( !acikYon[yon] || acikYon[(yon+2)%4] || acikYon[(yon + (yon%2==0?3:1 ))%4 ] )) {
        int acikIndex=(int)random(acikYonSayisi);
        int temp=-1;
        for (int i=0; i<4; i++) {
          if (acikYon[i]) {
            temp++;
            if (temp==acikIndex)
              yon=i;
          }
        }
      }
    } else {
      yon=-1;
    }
  }

  void bomberOldur(int treshold) {
    for (Bomber bomber : bomberList) {
      if ( !(bomber.walkX+bomber.img.width/2 < walkX-canavar.width/2+treshold || 
        bomber.walkX-bomber.img.width/2 > walkX+canavar.width/2-treshold ||
        bomber.walkY+bomber.img.height/2 < walkY-canavar.height/2+treshold || 
        bomber.walkY-bomber.img.height/2 > walkY+canavar.height/2-treshold) ) {
        if (bomber.dieTime==0) {
          vol_death.play(0);
          bomber.dieTime=millis();
        }
      }
    }
  }
}