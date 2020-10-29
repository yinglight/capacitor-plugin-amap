declare module '@capacitor/core' {
  interface PluginRegistry {
    ValleyAmap: ValleyAmapPlugin;
  }
}

export interface ValleyAmapPlugin {
  // 单次定位
  singleLocation(): Promise<any>;

  //持续定位
  continuousLocation(options: {isStart: boolean}): Promise<any>;
}
