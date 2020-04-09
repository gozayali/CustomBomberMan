public class Bomb {
  int x, y; 
  int pwr, waitPeriod, expPeriod;
  long setTime;
  boolean patladi, alanHesabi;
  String player;
  IntList patlamaX;
  IntList patlamaY;

  public Bomb(int _x, int _y, int _pwr, long _setTime, String _player ) {
    x=_x;
    y=_y;
    pwr=_pwr;
    waitPeriod=3000;
    expPeriod= 500;
    setTime=_setTime;
    area[x][y]=BOMB;
    player=_player;
    patladi=false;
    alanHesabi=false;
    vol_timer.play(2500);
  }

  void ciz() {

    image(empty, x*placePxl, y*placePxl);
    long duration=millis()-setTime;
    if (duration<waitPeriod) {
      waitAnim(duration);
    } else if (duration<waitPeriod+expPeriod) {
      if (!alanHesabi) {
        vol_bomb.play(1000);
        patlamaAlaniHesapla();
        alanHesabi=true;
        for (int i=0; i<patlamaX.size(); i++) {
          expSonrasiAlan(patlamaX.get(i), patlamaY.get(i));
        }
      }
      for (int i=0; i<patlamaX.size(); i++) {
        expSirasinda(patlamaX.get(i), patlamaY.get(i),10);
      }
      expAnim(duration-waitPeriod);
    } else {    
      patladi=true;
    }
  }

  void waitAnim(long time) {
    if ((time/500)%2==0)
      image(bomb, x*placePxl, y*placePxl);
    else
      image(bomb2, x*placePxl, y*placePxl);
  }

  void patlamaAlaniHesapla() {
    patlamaX=new IntList();
    patlamaY=new IntList();
    patlamaX.append(x);
    patlamaY.append(y);
    boolean[] OK = new boolean[]{true, true, true, true};
    for (int i=1; i<=pwr; i++) {
      //sola
      if (OK[0] && x-i>=0 && area[x-i][y]!=ROCK && (area[x-i+1][y]!=WOOD && area[x-i+1][y]!=HIDDEN_POWER && area[x-i+1][y]!=HIDDEN_EXTRA) ) {
        patlamaX.append(x-i);
        patlamaY.append(y);
      } else
        OK[0]=false;
      //sağa
      if (OK[1] && x+i<xSize && area[x+i][y]!=ROCK && (area[x+i-1][y]!=WOOD && area[x+i-1][y]!=HIDDEN_POWER && area[x+i-1][y]!=HIDDEN_EXTRA) ) {
        patlamaX.append(x+i);
        patlamaY.append(y);
      } else
        OK[1]=false;
      //yukarı
      if (OK[2] && y-i>=0 && area[x][y-i]!=ROCK && (area[x][y-i+1]!=WOOD && area[x][y-i+1]!=HIDDEN_POWER && area[x][y-i+1]!=HIDDEN_EXTRA) ) {
        patlamaX.append(x);
        patlamaY.append(y-i);
      } else
        OK[2]=false;
      //sağa
      if (OK[3] && y+i<ySize && area[x][y+i]!=ROCK && (area[x][y+i-1]!=WOOD && area[x][y+i-1]!=HIDDEN_POWER && area[x][y+i-1]!=HIDDEN_EXTRA) ) {
        patlamaX.append(x);
        patlamaY.append(y+i);
      } else
        OK[3]=false;
    }
  }

  void expAnim(long time) {
    PImage tempFlame;
    if ((time/100)%2==0)
      tempFlame=flame;
    else
      tempFlame=flame2;
    for (int i=0; i<patlamaX.size(); i++) {
      image(tempFlame, (patlamaX.get(i))*placePxl, (patlamaY.get(i))*placePxl);
    }
  }

  void expSonrasiAlan(int x, int y) {
    if (area[x][y]==BOMB || area[x][y]==POWER || area[x][y]==EXTRA || area[x][y]==WOOD) {
      area[x][y]=EMPTY;
    } else if (area[x][y]==HIDDEN_EXTRA) {
      area[x][y]=EXTRA;
    } else if (area[x][y]==HIDDEN_POWER) {
      area[x][y]=POWER;
    }
  }

  void expSirasinda(int x, int y, int treshold) {
    bomberDieControl(x, y,treshold);
    canavarDieControl(x, y,treshold);
  }  
  void bomberDieControl(int x, int y, int treshold) {
    for (Bomber bomber : bomberList) {
      if ( !(bomber.walkX+bomber.img.width/2 < x*placePxl+treshold || 
        bomber.walkX-bomber.img.width/2 > (x+1)*placePxl - treshold ||
        bomber.walkY+bomber.img.height/2 < y*placePxl+treshold || 
        bomber.walkY-bomber.img.height/2 > (y+1)*placePxl-treshold) ) {
        if (bomber.dieTime==0){
          vol_torch.play(0);
          bomber.dieTime=millis();
        }
      }
      for (Bomb bmb : bomber.bombs) {
        if (bmb.x==x && bmb.y==y && bmb.waitPeriod+bmb.setTime>millis())
          bmb.setTime=millis()-bmb.waitPeriod;
      }
    }
  }

  void canavarDieControl(int x, int y,int treshold) {
    for (Canavar c : canavarList) {
      if ( !(c.walkX+canavar.width/2 < x*placePxl +treshold || 
        c.walkX-canavar.width/2 > (x+1)*placePxl-treshold ||
        c.walkY+canavar.height/2 < y*placePxl+treshold || 
        c.walkY-canavar.height/2 > (y+1)*placePxl-treshold) ) {
        if (c.dieTime==0) {
          vol_torch.play(0);
          c.dieTime=millis();
          for (Bomber b : bomberList) {
            if (b.name.equalsIgnoreCase(player))            
              b.les++;
          }
        }
      }
    }
  }
}