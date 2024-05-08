class Box{
	//member values/ variables
	int a;
	int b;
	int c;
	public Box(int x, int y, int j){
		a = x;
		b = y;
		c = j;
	}
}

class Main{
	public static void main(String [] args){
		// creating object
		Box obj = new Box(5,6,7);
		System.out.println(obj.a);
		System.out.println(obj.b);
		System.out.println(obj.c);

	}
}
