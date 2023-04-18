public class aObject extends aGameObject {
  private int linkedNum, objectValue, setDistance, objectStart;
  private float objectSpeed;
  private String setType, portalType, objectDirection;
  private Boolean objectInfinite;


  public aObject(String setType, int visibility, int setX, int setY) {
    super(visibility, setX, setY, 0, 0);
    this.setType = setType;
  }

  public aObject(String setType, int visibility, int setX, int setY, int objectValue) {
    super(visibility, setX, setY, 0, 0);
    this.setType = setType;
    this.objectValue = objectValue;
  }

  public aObject(String setType, int visibility, int setX, int setY, int setDistance, float objectSpeed) {
    super(visibility, setX, setY, 0, 0);
    this.setType = setType;
    this.setDistance = setDistance;
    this.objectSpeed = objectSpeed;
    this.setX = objectStart;
  }

  public aObject(String setType, int visibility, int setX, int setY, int setL, int setW) {
    super(visibility, setX, setY, setL, setW);
    this.setType = setType;
  }

  public aObject(String setType, int visibility, int setX, int setY, int setL, int setW, String objectDirection, int setDistance, float objectSpeed) {
    super(visibility, setX, setY, setL, setW);
    this.setType = setType;
    this.setDistance = setDistance;
    this.objectDirection = objectDirection;
    this.objectSpeed = objectSpeed;
  }

  public aObject(String setType, int visibility, int setX, int setY, int setL, int setW, String objectDirection, boolean objectInfinite, float objectSpeed) {
    super(visibility, setX, setY, setL, setW);
    this.setType = setType;
    this.objectInfinite = objectInfinite;
    this.objectDirection = objectDirection;
    this.objectSpeed = objectSpeed;
  }

  public aObject(aObject other) {
    super(other.getVisibility(), other.getX(), other.getY(), other.getL(), other.getW());
    this.setType = other.setType;
    this.objectInfinite = other.objectInfinite;
    this.objectDirection = other.objectDirection;
    this.objectSpeed = other.objectSpeed;
  }

  public aObject(String setType, int visibility, String portalType, int setX, int setY, int linkedNum) {
    super(visibility, setX, setY, 0, 0);
    this.setType = setType;
    this.portalType = portalType;
    this.linkedNum = linkedNum;
  }



  public String getType() {
    return setType;
  }


  public int getLinkedNum() {
    return linkedNum;
  }




  public void handleCollision(aPlayer player) {
    if (visibility == 0 || visibility == getViewVisibility()) {

      if (player.getX() + player.getL() > getX() && player.getX() < getX() + getL() &&
        player.getY() + player.getW() > getY() && player.getY() < getY() + getW()) {

        switch(setType) {
        case "deathZone":

          world.reset();
          break;

        case "portal":

          for (aObject obj : objects) {
            if (obj.getType() == "portal" && getLinkedNum() == obj.getLinkedNum() && (obj.getX() != getX() || obj.getY() != getY())) {
              switch(obj.portalType) {

              case "RV":
                player.setX(obj.getX()+ 30);
                player.setY(obj.getY());
                break;

              case "LV":
                player.setX(obj.getX() - 30);
                player.setY(obj.getY());
                break;

              case "UH":
                player.setX(obj.getX());
                player.setY(obj.getY() - 30);
                player.jumpToggle = false;
                player.jump();
                break;

              case "DH":
                player.setX(obj.getX());
                player.setY(obj.getY() + 30);
                break;

              default:

                println("invalid portal type");
                break;
              }

              break;
            }
          }



          break;

        case "jumpBoost":
          player.jump = objectValue;
          player.jump();
          player.reset();
          break;

        case "ladder":
          if (player.getY() + player.getW() > getY() && player.getY() < getY() && player.getX() + player.getL() > getX() && player.getX() < getX() + getL() && !player.moveDown) {
            player.land();
            player.setY(getY() - player.getW());
          }
          player.velocityY = 0;
          player.ladder = true;
          break;
        case "podium":
          saveData();
          world.level++;
          world.spawn();
          world.statsReset();

          break;

        default:
          println("Invalid setType");
          break;
        }
      }
    }
  }


  public void saveData() {
    GUI.getData();

    // Set level data
    JSONObject levelData = new JSONObject();
    levelData.setFloat("levelTime", world.levelTimer);
    levelData.setInt("deaths", world.deathStat);
    levelData.setInt("jumps", world.jumpStat);
    levelData.setInt("left", world.leftStat);
    levelData.setInt("right", world.rightStat);

    // Get the worldArray and levelArray
    JSONArray worldArray = saveData.getJSONArray(world.world - 1);
    JSONArray levelArray = worldArray.getJSONArray(world.level - 1);

    if (levelArray.size() >= 10) {
      for (int i = levelArray.size() - 1; i > 0; i--) {
        levelArray.setJSONObject(i, levelArray.getJSONObject(i - 1));
      }
      levelArray.setJSONObject(0, levelData);
    } else {
      levelArray.append(levelData);
    }

    saveJSONArray(saveData, "data/stats.json");

    if (world.world > GUI.worldUnlocked) {
      println(GUI.worldUnlocked);
      json.setInt("worldUnlocked", world.world);
      json.setInt("levelUnlocked", world.level + 1);
      saveJSONObject(json, "data/data.json");
    } else if (world.world == GUI.worldUnlocked) {
      if (world.level + 1 >= GUI.levelUnlocked) {
        json = new JSONObject();
        json.setInt("worldUnlocked", world.world);
        json.setInt("levelUnlocked", world.level + 1);
        saveJSONObject(json, "data/data.json");
      }
    }
  }





  @Override
    public void display() {

    if (visibility == 0 || visibility == getViewVisibility()) {
      noStroke();
      if (setDistance >= 1 ) {

        switch(objectDirection) {
        case "horizontal":
          if (objectStart == 0) {
            objectStart = setX;
          }

          setX += objectSpeed;
          if (setX > setDistance) {
            objectSpeed = -objectSpeed;
          } else if (setX < objectStart) {
            objectSpeed = -objectSpeed;
          }
          break;

        case "vertical":
          if (objectStart == 0) {
            objectStart = setY;
          }
          setY += objectSpeed;
          if (setY > setDistance) {
            objectSpeed = -objectSpeed;
          } else if (setY < objectSpeed) {
            objectSpeed = -objectSpeed;
          }
          break;

        default:

          break;
        }
      }


      if (objectDirection != null && objectInfinite != null ) {

        switch(objectDirection) {
        case "horizontal":
          if (objectInfinite) {
            setX += objectSpeed;
          } else {
            setX -= objectSpeed;
          }
          break;

        case "vertical":
          if (objectInfinite) {
            setY += objectSpeed;
          } else {
            setY -= objectSpeed;
          }
          break;

        default:

          break;
        }
      }


      if (setDistance >= 1 ) {
        setX += objectSpeed;
        if (setX > setDistance) {
          objectSpeed = -objectSpeed;
        } else if (setX < objectStart) {
          objectSpeed = -objectSpeed;
        }
      }

      switch(setType) {

      case "deathZone":
        fill(255, 0, 0);
        rect(setX, setY, setL, setW);
        break;

      case "portal":

        fill(#C062E3);

        switch(portalType) {

        case "RV":
          setL = 10;
          setW = 60;
          rect(setX, setY, setL, setW);
          fill(255);
          rect(setX + 5, setY + 5, 5, 50);
          break;

        case "LV":
          setL = 10;
          setW = 60;
          rect(setX, setY, setL, setW);
          fill(255);
          rect(setX, setY + 5, 5, 50);
          break;

        case "UH":
          setL = 60;
          setW = 10;
          rect(setX, setY, setL, setW);
          fill(255);
          rect(setX + 5, setY, 50, 5);
          break;

        case "DH":
          setL = 60;
          setW = 10;
          rect(setX, setY, setL, setW);
          fill(255);
          rect(setX + 5, setY + 5, 50, 5);
          break;

        default:
          println("invalid portal type");
          break;
        }



        break;

      case "jumpBoost":
        setL = 35;
        setW = 10;
        fill(#4DCEFF);
        rect(setX, setY, setL, setW);
        break;


      case "projectileTarget":
        fill(#FF3E3E);
        rect(setX, setY, setL, setW);
        fill(255);
        rect(setX + 10, setY + 10, setL - 20, setW -20);
        fill(#FF3E3E);
        rect(setX + 15, setY + 15, setL - 30, setW -30);

        for (aPowerup pow : powerups) {
          if (pow.getType() == "projectile") {
            if ( pow.getProjectileY() <= (setY + setW) && pow.getProjectileY() >= (setY - 20) && pow.getProjectileX() >= (setX - 20) && pow.getProjectileX() <= (setX + setL)  + 20) {

              if (getViewVisibility() == 2) {
                setViewVisibility(1);
              } else {
                setViewVisibility(2);
              }

              updateVisibility();

              pow.projectileMove = false;
              pow.projectileX = 0;
              pow.projectileY = 0;
            }
          }
        }



        break;


      case "ladder":
        fill(#C1740E);
        rect(setX, setY, setL, setW);


        break;

      case "podium":
        setL = 35;
        setW = 10;
        fill(218, 165, 32);
        rect(setX, setY, setL, setW);
        break;
      default:
        println("Invalid setType");
      }
    }
  }

  public void data() {
    println(getVisibility());
    println(getViewVisibility());
  }
}
