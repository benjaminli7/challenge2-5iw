import 'package:flutter/material.dart';
import 'package:frontend/shared/models/hike.dart';

class HikeDetailsSection extends StatelessWidget {
  final Hike hike;
  const HikeDetailsSection({Key? key, required this.hike}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[

        CircleAvatar(
          backgroundImage: NetworkImage("https://fr.images.search.yahoo.com/images/view;_ylt=AwrEabgS2H1mcCohI49lAQx.;_ylu=c2VjA3NyBHNsawNpbWcEb2lkA2NlMDgxYmY5ZWM5MjU3MDM1YzRlMTM3YWE2YTM4NGRmBGdwb3MDMgRpdANiaW5n?back=https%3A%2F%2Ffr.images.search.yahoo.com%2Fsearch%2Fimages%3Fp%3Dimage%26type%3DE211FR885G0%26fr%3Dmcafee%26fr2%3Dpiv-web%26tab%3Dorganic%26ri%3D2&w=5797&h=3261&imgurl=my.alfred.edu%2Fzoom%2F_images%2Ffoster-lake.jpg&rurl=https%3A%2F%2Fmy.alfred.edu%2Fzoom%2F&size=1446.7KB&p=image&oid=ce081bf9ec9257035c4e137aa6a384df&fr2=piv-web&fr=mcafee&tt=Background+Images+%7C+My+Alfred+University&b=0&ni=21&no=2&ts=&tab=organic&sigr=FKMIbF8akNGU&sigb=3SuwSudKWyyq&sigi=W7MA4M_JeZnP&sigt=nhVjUsUCVx1P&.crumb=O9n9vJu8.GB&fr=mcafee&fr2=piv-web&type=E211FR885G0"), // Use your image asset or URL
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            hike.name,
            style: const TextStyle(fontSize: 18),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
