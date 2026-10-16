# SPDX-License-Identifier: GPL-3.0-or-later
"""Strict stdlib PNG pixels for physical scene and saved-image assertions."""
import struct,zlib

def png(raw):
 if raw[:8]!=b'\x89PNG\r\n\x1a\n':raise ValueError('PNG signature')
 pos=8;data=b'';header=None
 while pos<len(raw):
  if pos+12>len(raw):raise ValueError('PNG truncated')
  length=struct.unpack('>I',raw[pos:pos+4])[0];tag=raw[pos+4:pos+8];part=raw[pos+8:pos+8+length];crc=raw[pos+8+length:pos+12+length]
  if len(part)!=length or len(crc)!=4 or struct.unpack('>I',crc)[0]!=zlib.crc32(tag+part)&0xffffffff:raise ValueError('PNG CRC')
  if tag==b'IHDR':header=struct.unpack('>IIBBBBB',part)
  elif tag==b'IDAT':data+=part
  elif tag==b'IEND':break
  pos+=length+12
 if not header or header[2]!=8 or header[3] not in [2,6] or any(header[4:]):raise ValueError('PNG needs noninterlaced RGB/RGBA8')
 w,h,_,kind,*_=header;channels=3 if kind==2 else 4;stride=w*channels;filtered=zlib.decompress(data)
 if len(filtered)!=h*(stride+1):raise ValueError('PNG size')
 rows=[];previous=bytearray(stride)
 for y in range(h):
  at=y*(stride+1);f=filtered[at];row=bytearray(filtered[at+1:at+stride+1])
  if f>4:raise ValueError('PNG filter')
  for i in range(stride):
   left=row[i-channels] if i>=channels else 0;up=previous[i];corner=previous[i-channels] if i>=channels else 0
   predict=0
   if f==1:predict=left
   elif f==2:predict=up
   elif f==3:predict=(left+up)//2
   elif f==4:
    p=left+up-corner;dl,du,dc=abs(p-left),abs(p-up),abs(p-corner);predict=left if dl<=du and dl<=dc else up if du<=dc else corner
   row[i]=(row[i]+predict)&255
  rows.append(bytes(row));previous=row
 return (w,h,channels,rows)

def pixel(image,x,y):
 w,h,c,rows=image
 if not(0<=x<w and 0<=y<h):raise ValueError('Pixel outside image')
 return tuple(rows[y][x*c:x*c+3])

def changed(a,b,rect,tolerance=0):
 x,y,w,h=map(round,rect)
 return sum(any(abs(u-v)>tolerance for u,v in zip(pixel(a,col,row),pixel(b,col,row))) for row in range(y,y+h) for col in range(x,x+w))

def bounds(a,b,rect,tolerance=0):
 x,y,w,h=map(round,rect);count=0;left,top,right,bottom=x+w,y+h,x,y
 for row in range(y,y+h):
  for col in range(x,x+w):
   u=a[3][row][col*a[2]:col*a[2]+3];v=b[3][row][col*b[2]:col*b[2]+3]
   if (u!=v if not tolerance else any(abs(i-j)>tolerance for i,j in zip(u,v))):count+=1;left=min(left,col);top=min(top,row);right=max(right,col+1);bottom=max(bottom,row+1)
 return (count,(left,top,right,bottom) if count else None)
