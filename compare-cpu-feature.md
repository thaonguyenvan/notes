# Compare cpu feature beetweens 2 compute to know whether it can live mig or not

- Dump capabilities in node that you want to live mig from

`virsh capabilities > virsh-caps.xml`

- Edit this file, keep only block <cpu> like this:

```
<cpu>
      <arch>x86_64</arch>
      <model>core2duo</model>
      <topology sockets='1' cores='4' threads='1'/>
      <feature name='lahf_lm'/>
      <feature name='sse4.1'/>
      <feature name='xtpr'/>
      <feature name='cx16'/>
      <feature name='tm2'/>
      <feature name='est'/>
      <feature name='vmx'/>
      <feature name='ds_cpl'/>
      <feature name='pbe'/>
      <feature name='tm'/>
      <feature name='ht'/>
      <feature name='ss'/>
      <feature name='acpi'/>
      <feature name='ds'/>
</cpu>
```

- Move this file to node that you want to live mig to

- And compare

`virsh cpu-compare virsh-caps.xml`
