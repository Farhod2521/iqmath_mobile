import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../injector_container.dart';

class SecuritySwitch extends StatefulWidget {
  const SecuritySwitch({super.key});

  @override
  State<SecuritySwitch> createState() => _SecuritySwitchState();
}

class _SecuritySwitchState extends State<SecuritySwitch> {
  var bioMetrics = false;

  @override
  void initState() {
    bioMetrics = sl<LocalSource>().getBiometricsOn() ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoSwitch(
      value: bioMetrics,
      onChanged: (value) {
        setState(() {
          bioMetrics = value;
        });
        sl<LocalSource>().setBiometricsOn(value);
      },
    );
  }
}
