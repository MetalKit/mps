
import MetalKit
import MetalPerformanceShaders
import PlaygroundSupport

class Renderer: NSObject, MTKViewDelegate {
  
    public var device: MTLDevice!
    var queue: MTLCommandQueue!
    var texIn: MTLTexture!
    
    override init() {
        super.init()
        device = MTLCreateSystemDefaultDevice()
        queue = device.newCommandQueue()
        let textureLoader = MTKTextureLoader(device: device)
        let url = Bundle.main.urlForResource("nature", withExtension: "jpg")!
        do { texIn = try textureLoader.newTexture(withContentsOf: url, options: [:]) }
        catch _ { fatalError("Resource file cannot be loaded!") }
    }
    
    func draw(in view: MTKView) {
        let commandBuffer = queue.commandBuffer()
        let texOut = view.currentDrawable!.texture
        let shader = MPSImageGaussianBlur(device: device, sigma: 5)
        //let shader = MPSImageSobel(device: device)
        //let shader = MPSImageAreaMax(device: device, kernelWidth: 5, kernelHeight: 5)
        //let shader = MPSImageAreaMin(device: device, kernelWidth: 5, kernelHeight: 5)
        //let shader = MPSImageMedian(device: device, kernelDiameter: 3)
        //let shader = MPSImageBox(device: device, kernelWidth: 9, kernelHeight: 9)
        //let shader = MPSImageTent(device: device, kernelWidth: 9, kernelHeight: 9)
        shader.encode(commandBuffer: commandBuffer, sourceTexture: texIn, destinationTexture: texOut)
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }
  }

let frame = CGRect(x: 0, y: 0, width: 400, height: 400)
let delegate = Renderer()
let view = MTKView(frame: frame, device: delegate.device)
view.delegate = delegate
PlaygroundPage.current.liveView = view
