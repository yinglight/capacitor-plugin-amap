import { WebPlugin } from '@capacitor/core';
import { ValleyAmapPlugin } from './definitions';

export class ValleyAmapWeb extends WebPlugin implements ValleyAmapPlugin {
  constructor() {
    super({
      name: 'ValleyAmap',
      platforms: ['web'],
    });
  }

  async singleLocation(): Promise<any> {
    console.log('SingleLocation');
    return '';
  }

  async continuousLocation(options: { isStart: boolean; }): Promise<any> {
    console.log('ContinuousLocation');
    return options;
  }
}

const ValleyAmap = new ValleyAmapWeb();

export { ValleyAmap };

import { registerWebPlugin } from '@capacitor/core';
registerWebPlugin(ValleyAmap);
