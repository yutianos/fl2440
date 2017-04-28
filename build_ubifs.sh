#!/bin/sh
#+--------------------------------------------------------------------------------------------
#|Description: This shell script is used to generate a UBIFS rootfs for K9F2G08 nandflash
#|     Author:  GuoWenxue <guowenxue@gmail.com> QQ: 281143292 凌云嵌入式学习
#|  ChangeLog:
#|           1, Initialize 1.2.0 on 2013.05.4
#|  Reference: 
#|       http://www.linux-mtd.infradead.org/faq/ubifs.html
#|       http://blog.sina.com.cn/s/blog_5b9ea9840100apqc.html
#+--------------------------------------------------------------------------------------------

#===================================================================
#  U-BOOT print the Rootfs partition UBI information for reference +
#===================================================================
#U-Boot> mtdparts default
#U-Boot> mtdparts 

#device nand0 <nand0>, # parts = 4
# #: name                size            offset          mask_flags
# 0: uboot               0x00100000      0x00000000      0
# 1: kernel              0x00400000      0x00100000      0
# 2: ramdisk             0x00a00000      0x00500000      0
# 3: cramfs              0x00f00000      0x00f00000      0
# 4: jffs2               0x02800000      0x01e00000      0
# 5: yaffs2              0x02800000      0x04600000      0
# 6: ubifs               0x02800000      0x06e00000      0
# 7: info                0x00100000      0x09600000      0
# 8: apps                0x02800000      0x09700000      0
# 9: data                0x02800000      0x0bf00000      0
# 10:backup              0x01900000      0x0e700000      0
# active partition: nand0,0 - (bootloader) 0x00100000 @ 0x00000000
#
# defaults:
#     mtdids  : nand0=nand0

#===================================================================
#  Linux kenrel print nandflash partition information for reference +
#===================================================================
#Creating 9 MTD partitions on "NAND":
#0x000000000000-0x000000100000 : "mtdblock0 u-boot 1MB"
#0x000000100000-0x000001000000 : "mtdblock1 kernel 15MB"
#0x000001000000-0x000002400000 : "mtdblock2 ramdisk 20MB"
#0x000002400000-0x000003800000 : "mtdblock3 cramfs 20MB"
#0x000003800000-0x000006000000 : "mtdblock4 jffs2 40MB"
#0x000006000000-0x000008800000 : "mtdblock5 yaffs2 40MB"
#0x000008800000-0x00000b000000 : "mtdblock6 ubifs 40MB"
#0x00000b000000-0x00000d800000 : "mtdblock7 apps 40MB"
#0x00000d800000-0x000010000000 : "mtdblock8 data 40MB"
#UBI: attaching mtd6 to ubi0
#UBI: physical eraseblock size:   131072 bytes (128 KiB)
#UBI: logical eraseblock size:    129024 bytes
#UBI: smallest flash I/O unit:    2048
#UBI: sub-page size:              512
#UBI: VID header offset:          512 (aligned 512)
#UBI: data offset:                2048
#UBI: max. sequence number:       0
#UBI: volume 0 ("rootfs") re-sized from 300 to 312 LEBs
#UBI: attached mtd6 to ubi0
#UBI: MTD device name:            "mtdblock6 ubifs 40MB"
#UBI: MTD device size:            40 MiB
#UBI: number of good PEBs:        319
#UBI: number of bad PEBs:         1
#UBI: number of corrupted PEBs:   0
#UBI: max. allowed volumes:       128
#UBI: wear-leveling threshold:    4096
#UBI: number of internal volumes: 1
#UBI: number of user volumes:     1
#UBI: available PEBs:             0
#UBI: total number of reserved PEBs: 319
#UBI: number of PEBs reserved for bad PEB handling: 3
#UBI: max/mean erase counter: 1/0
#UBI: image sequence number:  124781291
#UBI: background thread "ubi_bgt0d" started, PID 439


#===================================================================
#   Shell script body start here                                   +
#===================================================================

#-r, -d, --root=DIR   root filesystem source code tree
rootfs_dir=rootfs
partition_sizeM=60
image_name=rootfs.ubifs


#Default setting by UBIFS
sub_page_size=512
vid_head_offset=512

#-m, minimum I/O unit size, it's 2K(the Page size) on K9F2G08, refer to "UBI: smallest flash I/O unit:    2048" 
page_size_in_bytes=2048
#It's 64 pages per block on K9F2G08
pages_per_block=64
block_size_in_bytes=`expr $page_size_in_bytes \* $pages_per_block`                                                                                                             
#echo "[$pages_per_block] pages per block and [$block_size_in_bytes] bytes"

#It's 2048 blocks on K9F2G08
blocks_per_device=2048
#echo "Blocks per device  [$blocks_per_device]"

#-e, logical erase block size, fixed on K9F2G08, refer to u-boot information "UBI: logical eraseblock size:  129024 bytes"
# logical erase block size is physical erase block size minus 1 page for UBI
logical_pages_per_block=`expr $pages_per_block - 1`
logical_erase_block_size=`expr $page_size_in_bytes \* $logical_pages_per_block`
#echo "Logical erase block size:  [$logical_erase_block_size] bytes."

# wear_level_reserved_blocks is 1% of total blcoks per device
wear_level_reserved_blocks=`expr $blocks_per_device / 100 + 10`
#echo "Reserved blocks for wear level ["ear_level_reserved_blocks]"

#The rootfs partition size in bytes
partition_size_in_bytes=`expr $partition_sizeM \* 1024 \* 1024`
partition_physical_blocks=`expr $partition_size_in_bytes / $block_size_in_bytes`
#echo "Partition size [$partition_size_in_bytes] bytes and [$partition_physical_blocks] blocks."

#Logical blocks on a partition = physical blocks on a partitiion - reserved for wear level 
patition_logical_blocks=`expr $partition_physical_blocks - $wear_level_reserved_blocks`
echo $patition_logical_blocks
#echo "Logical blocks in a partition [$patition_logical_blocks]"

#File-system volume = Logical blocks in a partition * Logical erase block size
fs_vol_size=`expr $patition_logical_blocks \* $logical_erase_block_size`
#echo "File-system volume [$fs_vol_size] bytes."

config_file=rootfs_ubinize.cfg
image_tmp=rootfs.img

echo ""
echo "Generating $image_tmp file by mkfs.ubifs..."
set -x
sudo /usr/bin/mkfs.ubifs -x lzo -m $page_size_in_bytes -e $logical_erase_block_size -c $patition_logical_blocks -r $rootfs_dir -o $image_tmp
set +x

echo
echo "Generating configuration file..."
echo "[ubifs-volume]" > $config_file
echo "mode=ubi" >> $config_file
echo "image=$image_tmp" >> $config_file
echo "vol_id=0" >> $config_file
echo "vol_size=$fs_vol_size" >> $config_file
echo "vol_type=dynamic" >> $config_file
echo "vol_name=rootfs" >> $config_file
echo "vol_flags=autoresize" >> $config_file
echo "vol_alignment=1" >> $config_file
echo

set -x
sudo ubinize -o $image_name -m $page_size_in_bytes -p $block_size_in_bytes -s $sub_page_size -O $vid_head_offset $config_file
set +x
sudo rm -f $image_tmp $config_file

