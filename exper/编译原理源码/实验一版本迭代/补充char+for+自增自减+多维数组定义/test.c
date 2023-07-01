int a,b,c;
float m,n;
char p,q;
int d[2];
int e[2][3];
int f[2][3][4];
int fibo(int a) {
	if (a==1 || a==2) 
		return 1;
	return fibo(a-1)+fibo(a-2);
}
int main(){
	int g[5][6];	
	char pp,qq;
	int m,n,i;
	int z=0;
	pp='\';
	qq=".";
	m=read();
	i=1;
	
	i++;
	i--;
	++i;
	--i;
	
	i=++i;
	
	for(int z=0,x=6;z<=10;z++) {
		write(z);
		break;
	}
	while(i<=m)
	{
		n=fibo(i);
		write(n);
		i=i+1;
		continue;
	}
	
	
	
	return 1;	
}