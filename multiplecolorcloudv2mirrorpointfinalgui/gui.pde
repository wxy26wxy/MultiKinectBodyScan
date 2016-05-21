public class Slider
{
    float x, y, width, height;
    float valueX = 0, value;
    boolean on;
    
    Slider ( float xx, float yy, float ww, float hh ) 
    {
        x = xx; 
        y = yy; 
        width = ww; 
        height = hh;     
        valueX = x;    
        Interactive.add( this );
    }
    
    void mouseEntered ()
    {
        on = true;
    }
    
    void mouseExited ()
    {
        on = false;
    }
    
    void mouseDragged ( float mx, float my )
    {
        valueX = mx - height/2;     
        if ( valueX < x ) valueX = x;
        if ( valueX > x+width-height ) valueX = x+width-height;       
        value = map( valueX, x, x+width-height, 0, 1 );     
        Interactive.send( this, "valueChanged", value );
    }
    
    public void draw ()
    {
        noStroke();
        
        fill( 100 );
        rect( x, y, width, height );
        
        fill( on ? 200 : 120 );
        rect( valueX, y, height, height );
    }
}


class SliderHandle
{
    float x,y,width,height;
    
    SliderHandle ( float xx, float yy, float ww, float hh )
    {
        this.x = xx; this.y = yy; this.width = ww; this.height = hh;
    }
    
    void draw ()
    {
        rect( x, y, width, height );
    }
    
    public boolean isInside ( float mx, float my )
    {
        return Interactive.insideRect( x, y, width, height, mx, my );
    }
}
